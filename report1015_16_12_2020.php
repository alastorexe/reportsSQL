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

// skbonus.ru
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
@ini_set('magic_quotes_gpc', 0);
@ini_set('magic_quotes_runtime', 0);
@ini_set('magic_quotes_sybase', 0);
@ini_set('register_globals', 0);

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
Необходимо выгрузить 2 отчета в период с 01.06.2020-16.12.2020 по всем клиентам:

1 отчет:

1) Номер карты
2) ФИО
3) НОмер телефона
4) Бонусный баланс сейчас на карте
5) Общая сумма накоплений
6) Кол-во списанных бонусов за весь период
7) Кол-во начисленных бонусов за весь период
8) Общее кол-во покупок


2 отчет:

1) Номер карты
2) ФИО
3) Дата продажи
4) Сумма продажи
5) Наименование товара в чеке
6) Сколько было списано бонусов
7) Сколько было начислено бонусов
*/

$sql = "SELECT
  cards.id,
  cards.uid,
  profiles.name,
  profiles.phone,
  cards.balance,
  sum(orders.summary) as sum,
  count(DISTINCT orders.id) as countOrder
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  INNER JOIN orders ON orders.card_id = cards.id
WHERE cards.client_id = 1015
AND orders.from >= '2020-06-01'
AND orders.from <= '2020-12-16 23:59:59'
GROUP BY cards.id";

$cards = ORM::forTable("cards")
    ->rawQuery($sql)
    ->findArray();

echo "Закончили формировать карты\n";

$sqlAddBonus = "SELECT orders.card_id, sum(balance_movements.change_sum) as addBonus
               FROM orders
                 INNER JOIN balance_movements ON orders.id = balance_movements.order_id
               WHERE orders.client_id = 1015
                 AND balance_movements.is_positive = 1
                 AND orders.from >= '2020-06-01'
                 AND orders.from <= '2020-12-16 23:59:59'
               GROUP BY orders.card_id";

$addBonus = ORM::forTable("orders")
    ->rawQuery($sqlAddBonus)
    ->findArray();

$sqlRemoveBonus = "SELECT orders.card_id, sum(balance_movements.change_sum) as removeBonus
               FROM orders
                 INNER JOIN balance_movements ON orders.id = balance_movements.order_id
               WHERE orders.client_id = 1015
                     AND balance_movements.is_positive = 0
                     AND orders.from >= '2020-06-01'
                     AND orders.from <= '2020-12-16 23:59:59'
               GROUP BY orders.card_id";

$removeBonus = ORM::forTable("orders")
    ->rawQuery($sqlRemoveBonus)
    ->findArray();

echo "Закончили формировать бонусы\n";

foreach ($cards as $card) {

    $addBonusCard = 0;
    $removeBonusCard = 0;

    foreach ($addBonus as $bonus){
        if($bonus["card_id"] == $card["id"]){
            $addBonusCard = $bonus["addBonus"];
            break;
        }
    }

    foreach ($removeBonus as $bonus) {
        if($bonus["card_id"] == $card["id"]){
            $removeBonusCard = $bonus["removeBonus"];
            break;
        }
    }

    $str = "'" . $card["uid"] . "'" . ";" . "'" . $card["name"] . "'" . ";" . "'" . $card["phone"] . "'" . ";"
        . "'" . $card["balance"] . "'" . ";" . "'" . $card["sum"] . "'" . ";" . "'" . $removeBonusCard . "'" . ";"
        . "'" . $addBonusCard . "'" . ";" . "'" . $card["countOrder"] . "'" . "\n";

    file_put_contents("report1015_16_12_2020.csv", $str, FILE_APPEND);
}