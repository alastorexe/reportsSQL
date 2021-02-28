<?php

define('DOCROOT', realpath(dirname(__FILE__))); //Абсолютный путь до корня проекта (каталог файла index.php) без слеша на конце
define('APPPATH', realpath('app') . DIRECTORY_SEPARATOR); //Каталог приложения
define('INCLUDESPATH', APPPATH . 'includes' . DIRECTORY_SEPARATOR); //Каталог подключамых файлов
define('SYSPATH', APPPATH . 'classes' . DIRECTORY_SEPARATOR); //Каталог автоподключаемых классов
require_once INCLUDESPATH . 'check_functions.php';//Load function checker
// Подключение composer

require_once DOCROOT . '/vendor/autoload.php';
//Подключение и инициализация автозагрузчика классов
require_once SYSPATH . 'Autoloader.php';
Autoloader::register();

define("CONFIG_MYSQL", [
    "host"        => "rc1a-43bu904s7cn0e1kl.mdb.yandexcloud.net",
    "password"    => "shah5Aifae9iZooxaighoh7g",
    "user"        => "user_loyalty_main",
    "database"    => "database_loyalty_main",
    "with_cert"   => true,
    "certificate" => DOCROOT . "/upload/certs/yandex_database.crt",
]);

// локальный конфиг
/*define("CONFIG_MYSQL", [
    "host"        => "localhost",
    "database"    => "skbonus_main",
    "user"        => "root",
    "password"    => "",
    "with_cert"   => false,
    "certificate" => null,
]);*/
//Настройка переменных окружения PHP
@ini_set("magic_quotes_gpc", 0);
@ini_set("magic_quotes_runtime", 0);
@ini_set("magic_quotes_sybase", 0);
@ini_set("register_globals", 0);

// Инициализация ORM
ORM::configure("mysql:host=" . CONFIG_MYSQL["host"] . ";dbname=" . CONFIG_MYSQL["database"]);
ORM::configure("username", CONFIG_MYSQL["user"]);
ORM::configure("password", CONFIG_MYSQL["password"]);
ORM::configure("logging", true);
$config = [
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8",
];
if (CONFIG_MYSQL["with_cert"] === true) {
    $config[PDO::MYSQL_ATTR_SSL_CA] = CONFIG_MYSQL["certificate"];
}
ORM::configure("driver_options", $config);

/*
Необходимо заполнить отчет во вложении по определенным артикулам, дата в таблице.

Группы по которым смотрим продажи в таблице

Группа Кофейники 496979 - 1920
КОФЕЙНИКИ 89р АЗС8 - 1968
ГРУППА ХОТдог за 88 - 1918
ГРУППА антиобледенитель - 1919
Группа НАПИТКИ - 1921
Группа Чай 29в асс - 1942
ГРУППА Кофейники НОВЫЕ - 1966
Нордвей -20С Спеццена ГРУППА - 1965
*/

$dateTo = "2021-02-22";
$dateFrom = "2021-02-28 23:59:59";

const GROUP_COFFEE_496979 = [
    "name"    => "Группа Кофейники 496979",
    "id"      => 1920,
    "article" => "'017811', '017812', '017813', '008548', '003223', '017817'",
];
const GROUP_COFFEE_89P_AZS8 = [
    "name"    => "КОФЕЙНИКИ 89р АЗС8",
    "id"      => 1968,
    "article" => "'017811', '017812', '017813'",
];
const GROUP_HOTDOG_88P = [
    "name"    => "ГРУППА ХОТдог за 88",
    "id"      => 1918,
    "article" => "'024528'",
];
const GROUP_DEICER = [
    "name"    => "ГРУППА антиобледенитель",
    "id"      => 1919,
    "article" => "'025531'",
];
const GROUP_DRINKS = [
    "name"    => "Группа НАПИТКИ",
    "id"      => 1921,
    "article" => "'022783', '020403', '013919', '013918'",
];
const GROUP_18636 = [
    "name"    => "Группа Чай 29в асс",
    "id"      => 1942,
    "article" => "'017775'",
];
const GROUP_COFFEE_NEW = [
    "name"    => "ГРУППА Кофейники НОВЫЕ",
    "id"      => 1966,
    "article" => "'017811', '017812', '017813'",
];
const GROUP_NOORDWAY = [
    "name"    => "Нордвей -20С Спеццена ГРУППА",
    "id"      => 1965,
    "article" => "'021092'",
];

const AVAILABLE_GROUP = [
    GROUP_COFFEE_496979,
    GROUP_COFFEE_89P_AZS8,
    GROUP_HOTDOG_88P,
    GROUP_DEICER,
    GROUP_DRINKS,
    GROUP_18636,
    GROUP_COFFEE_NEW,
    GROUP_NOORDWAY,
];

foreach (AVAILABLE_GROUP as $group) {
    $profilesORMs = ORM::forTable("buyers_list")
        ->selectExpr("buyers")
        ->where([
            "buyer_list_id" => $group["id"],
        ])->findOne();

    $profiles = str_replace('"', "'", $profilesORMs->buyers);
    $profiles = str_replace("[", "(", $profiles);
    $profiles = str_replace("]", ")", $profiles);

    $shops = '';
    if($group == GROUP_COFFEE_89P_AZS8) {
        $shops = "AND orders.shop_id IN (2297, 2298)";
    }

    $sql = "
    SELECT
    good.article,
    count(good.id) as amount
    FROM cards
    INNER JOIN (
               SELECT
                 orders.*,
                 goods.article
               FROM orders
                 INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 INNER JOIN goods ON goods.id = goods_incomes.goods_id
               WHERE orders.client_id = 625
                     {$shops}
                     AND orders.from >= '{$dateTo}'
                     AND orders.from <= '{$dateFrom}'
                     AND goods.article IN ({$group["article"]})
             ) AS good ON good.card_id = cards.id
    WHERE cards.client_id = 625
      AND cards.profile_id IN {$profiles}
    GROUP BY good.article";

    $goods = ORM::forTable("cards")
        ->rawQuery($sql)
        ->findArray();

    foreach ($goods as $good) {

        $str = "'" . $group["name"] . "'" . ";" . "'" . $good["article"] . "'" . ";" . "'" . $good["amount"] . "'" . ";" . "\n";

        file_put_contents("report625_{$dateFrom}.csv", $str, FILE_APPEND);
    }

    $str = "\n\n";

    file_put_contents("report625_{$dateFrom}.csv", $str, FILE_APPEND);
}

$sql = "
    SELECT
    good.article,
    count(good.id) as amount
    FROM cards
    INNER JOIN (
               SELECT
                 orders.*,
                 goods.article
               FROM orders
                 INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 INNER JOIN goods ON goods.id = goods_incomes.goods_id
               WHERE orders.client_id = 625
                     AND orders.from >= '{$dateTo}'
                     AND orders.from <= '{$dateFrom}'
                     AND goods.article IN (
                 '017811',
                 '017812',
                 '017813',
                 '017814',
                 '015912',
                 '016163',
                 '016172',
                 '016074',
                 '021662'
               )
             ) AS good ON good.card_id = cards.id
    WHERE cards.client_id = 625
    GROUP BY good.article";

$goods = ORM::forTable("cards")
    ->rawQuery($sql)
    ->findArray();

foreach ($goods as $good) {

    $str = "'" . "Все гости с программой лояльности CARAWAY" . "'" . ";" . "'" . $good["article"] . "'" . ";" . "'" . $good["amount"] . "'" . ";" . "\n";

    file_put_contents("report625_{$dateFrom}.csv", $str, FILE_APPEND);
}
