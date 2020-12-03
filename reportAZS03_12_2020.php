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
Нужно выбрать карты Светофор ( эти карты начинаются с цифр 220950000....) и выгрузить их в таблицу Excel, со следующими данными:

1) Номер карты
2) Дата привязки профиля к карте
3) Кол-во чеков за весь период
4) Дата последнего чека
5) Номер телефона
6) Общая сумма начисленных бонусов за весь период
7) Общая сумма потраченных бонусов за весь период
*/

$sql = "SELECT
  cards.id,
  cards.uid,
  history_profiles_change.created_at,
  COUNT(orders.id) AS count_orders,
  MAX(orders.from) AS max_date,
  profiles.phone
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  INNER JOIN orders ON orders.card_id = cards.id
  INNER JOIN history_profiles_change ON history_profiles_change.profile_id = profiles.id
WHERE cards.client_id = 625
      AND cards.uid LIKE '220950000%'
GROUP BY cards.id";

$cards = ORM::forTable("cards")
    ->rawQuery($sql)
    ->findArray();

echo "Закончили формировать карты\n";

$sqlBonuses = "
SELECT 
    balance_movements.card_id, 
    balance_movements.change_sum AS use_bonus, 
    balance_movements.is_positive
FROM cards
  INNER JOIN balance_movements ON cards.id = balance_movements.card_id
WHERE cards.client_id = 625
      AND cards.uid LIKE '220950000%'";

$bonuses = ORM::forTable("cards")
    ->rawQuery($sqlBonuses)
    ->findArray();

echo "Закончили формировать бонусы\n";

$addBonusesToCards = [];
$removeBonusesToCards = [];

// очень большой перебор. Так делать нельзя.
foreach ($cards as $card) {
    foreach ($bonuses as $bonus) {
        if ($card["id"] == $bonus["card_id"]) {
            $addBonusesToCards[$card["id"]] = 0;
            $removeBonusesToCards[$card["id"]] = 0;
            if ($bonus["is_positive"] == 1) {
                $addBonusesToCards[$card["id"]] += $bonus["use_bonus"];
            } else {
                $removeBonusesToCards[$card["id"]] += $bonus["use_bonus"];
            }
        }
    }
}

echo "Закончили формировать данные\n";

foreach ($cards as $card) {

    $addBonus = empty($addBonusesToCards[$card["id"]]) ? 0 : $addBonusesToCards[$card["id"]];
    $removeBonus = empty($removeBonusesToCards[$card["id"]]) ? 0 : $removeBonusesToCards[$card["id"]];

    $str = "'" . $card["uid"] . "'" . ";" . "'" . $card["created_at"] . "'" . ";" . "'" . $card["count_orders"] . "'" . ";"
        . "'" . $card["max_date"] . "'" . ";" . "'" . $card["phone"] . "'" . ";" . "'" . $addBonus . "'" . ";"
        . "'" . $removeBonus . "'" . "\n";

    file_put_contents("report625_03_12_2020.csv", $str, FILE_APPEND);
}