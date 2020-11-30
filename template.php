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

//Чтение конфигурационного файла
require_once INCLUDESPATH . 'config_local.php';

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

$sql = "SELECT * FROM cards";

$orders = ORM::forTable("cards")
    ->rawQuery($sql)
    ->findArray();
