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

// Массив сум для промежутков
$summaryItems = [
    100,
    700,
    800,
    900,
    1000,
    1100,
    1200,
    1300,
    1400,
    1500,
];

/*Необходимо выгрузить данные по неделям за ноябрь в таблицу Excel:

1лист: Номер карты, Кол-во заправок, Средний чек, Вид топлива ( период с 01.11-08.11)
2лист: Номер карты, Кол-во заправок, Средний чек, Вид топлива (Период 09.11-15.11)
3 лист:  Номер карты, Кол-во заправок, Средний чек, Вид топлива ( период 16.11-22.11)
4 лист :  Номер карты, Кол-во заправок, Средний чек, Вид топлива ( период 23.11-30.11)


Брать чеки только на суммы от 299-600 рублей по топливу.
Список артикулов:

ДТ-З-К5,
ДТ-З-К5 GT
АИ-98-К5
АИ-95-К5
АИ-95-К5
АИ-95-К5 GT
АИ-92-К5
АИ-92-К5
023451
019356
СУГ
АИ-92 GT*/

$sql = "
SELECT cards.uid, count(orders.id) as counts, round(AVG(orders.summary), 2) as avgsum, group_concat(DISTINCT goods.article separator ', ')
FROM cards
  inner JOIN profiles ON profiles.id = cards.profile_id
  inner JOIN orders ON cards.id = orders.card_id
  inner JOIN goods_incomes ON orders.id = goods_incomes.order_id
  inner JOIN goods ON goods_incomes.goods_id = goods.id
WHERE cards.client_id = 625
      AND goods.article IN (
  'ДТ-З-К5',
  'ДТ-З-К5 GT',
  'АИ-98-К5',
  'АИ-95-К5',
  'АИ-95-К5',
  'АИ-95-К5 GT',
  'АИ-95-К5 GT',
  'АИ-92-К5',
  'АИ-92-К5',
  '023451',
  '019356',
  'СУГ',
  'АИ-92 GT'
)
      AND orders.summary >= 299
      AND orders.summary <= 600
      AND orders.from >= '2020-11-23'
      AND orders.from <= '2020-11-30 23:59:59'
group by cards.id;
";

$orders = ORM::forTable("cards")
    ->rawQuery($sql)
    ->findArray();
