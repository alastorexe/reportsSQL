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

$sql = "select sale_general_report from 
  reports_configurations
  where client_id = 888";

$groupShops = ORM::forTable("reports_configurations")
    ->rawQuery($sql)
    ->findOne();

$groups = json_decode($groupShops["sale_general_report"]);

$sql = "SELECT
  shops.name as shopName,
  profiles.name,
  profiles.phone,
  shops.id as shopID,
  hpc.created_at
FROM cards
  LEFT OUTER JOIN orders ON orders.card_id = cards.id
  INNER JOIN profiles ON profiles.id = cards.profile_id
  INNER JOIN shops ON orders.shop_id = shops.id
  LEFT OUTER JOIN (
                    SELECT *
                    FROM history_profiles_change
                    WHERE client_id = 888
                          AND is_creation = TRUE
                  ) AS hpc ON hpc.profile_id = profiles.id
WHERE cards.client_id = 888
  and hpc.created_at >= '2020-10-07'
  and hpc.created_at <= '2020-12-29 23:59:59'
GROUP BY cards.id;";

$cards = ORM::forTable("cards")
    ->rawQuery($sql)
    ->findMany();

foreach ($cards as $card) {
    $groupName = null;

    foreach ($groups as $group) {
        $shops = $group->shops;
        if(in_array($card["shopID"], $shops)) {
            $groupName = $group->name;
            break;
        }
        /* foreach ($shops as $shop) {
             if ($card["shop_id"] == $shop) {
                 $groupName = $group->name;
                 break;
             }
         }*/
    }

    $str = "'" . $groupName . "'" . ";" . "'" . $card["shopName"] . "'" . ";" . "'" . $card["name"] . "'" . ";"
        . "'" . $card["phone"] . "'" . ";" . "'" . $card["created_at"] . "'" . ";" . "\n";

    file_put_contents("report888_29_12_2020.csv", $str, FILE_APPEND);
}