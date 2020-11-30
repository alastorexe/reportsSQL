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
/*define("CONFIG_MYSQL", [
    "host"        => "rc1a-43bu904s7cn0e1kl.mdb.yandexcloud.net",
    "password"    => "shah5Aifae9iZooxaighoh7g",
    "user"        => "user_loyalty_main",
    "database"    => "database_loyalty_main",
    "with_cert"   => true,
    "certificate" => DOCROOT . "/upload/certs/yandex_database.crt",
]);*/

// локальный конфиг
define("CONFIG_MYSQL", [
    "host"        => "localhost",
    "database"    => "skbonus_main",
    "user"        => "root",
    "password"    => "",
    "with_cert"   => false,
    "certificate" => null,
]);

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

// создаём список
$buyerList = ORM::forTable("buyer_lists")->create();
$buyerList->set([
    "client_id"  => 625,
    "autoupdate" => false,
    "name"       => "Список до 3999,99.",
    "created_at" => date("Y-m-d h:i:s"),
]);
if ($buyerList->save() === false) {
    throw new OrlanException("Не удалось сохранить Список, попробуйте еще раз.");
}

// Создаём привязку пользователей к списку
$list = ORM::forTable("buyers_list")->create();
$list->set([
    "buyer_list_id" => $buyerList->id,
    "buyers"        => "[]",
]);
$list->save();

$buyers = [];

/* Лучше делать руками и заносить в базу.
Сформировать три списка по клиентам, у которых:

1. установлено мобильное приложение и/или электронная карта
2. вся сумма чеков за период с 01.11-30.11
3. учитывать все товары

1 список до 3999,99 руб
2 список от 4000 до 7999,99 руб
3 список от 8000 руб*/

// запрос cформировать список пользователей
// Список до 3999.99
$sql = "
SELECT profiles.id FROM cards
  inner join profiles on  profiles.id = cards.profile_id
  inner JOIN orders ON orders.card_id = cards.id
  left outer join push_info on push_info.profile_id = profiles.id
  left outer join google_pay_infos on google_pay_infos.profile_id = profiles.id
  left outer join (select * from profiles_worksheets where worksheet_id = 207 and value = '1') as pw on pw.profile_id = profiles.id
WHERE cards.client_id = 625
  and (push_info.id is not null or google_pay_infos.id IS NOT null or pw.value is NOT null)
  AND orders.from >= '2020-11-01'
  AND orders.from <= '2020-11-30 23:59:59'
GROUP BY profiles.id
HAVING SUM(orders.summary) < 4000
";

// список от 4000 до 7999.99
$sql = "
SELECT profiles.id FROM cards
  inner join profiles on  profiles.id = cards.profile_id
  inner JOIN orders ON orders.card_id = cards.id
  left outer join push_info on push_info.profile_id = profiles.id
  left outer join google_pay_infos on google_pay_infos.profile_id = profiles.id
  left outer join (select * from profiles_worksheets where worksheet_id = 207 and value = '1') as pw on pw.profile_id = profiles.id
WHERE cards.client_id = 625
  and (push_info.id is not null or google_pay_infos.id IS NOT null or pw.value is NOT null)
  AND orders.from >= '2020-11-01'
  AND orders.from <= '2020-11-30 23:59:59'
GROUP BY profiles.id
HAVING SUM(orders.summary) > 4000
AND SUM(orders.summary) < 8000
";

// список от 8000
$sql = "
SELECT profiles.id FROM cards
  inner join profiles on  profiles.id = cards.profile_id
  inner JOIN orders ON orders.card_id = cards.id
  left outer join push_info on push_info.profile_id = profiles.id
  left outer join google_pay_infos on google_pay_infos.profile_id = profiles.id
  left outer join (select * from profiles_worksheets where worksheet_id = 207 and value = '1') as pw on pw.profile_id = profiles.id
WHERE cards.client_id = 625
  and (push_info.id is not null or google_pay_infos.id IS NOT null or pw.value is NOT null)
  AND orders.from >= '2020-11-01'
  AND orders.from <= '2020-11-30 23:59:59'
GROUP BY profiles.id
HAVING SUM(orders.summary) >= 8000
";

$buyerORMs = ORM::forTable("cards")
    ->rawQuery($sql)
    ->findArray();

foreach ($buyerORMs as $buyerORM) {
    $buyers[] = $buyerORM->id;
}

sort($buyers);


$list->buyers = json_encode($buyers);
$list->save();
