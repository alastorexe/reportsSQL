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
@ini_set("memory_limit", "-1");

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
Необходимо создать скрипт для загрузки товаров из файла в skbonus.

Пример Файла загрузки прикрепляю ( Декорадо)
*/

/**
 * Parse xml string to array
 * Example input string and output array in begin function
 *
 * @param SimpleXMLElement $xmlObject
 *
 * @return array
 * @throws Exception
 */
function _parseXML($xmlObject)
{
    /*
         * Input string
        <package>
          <message>
            <msg id="1234" sms_id="0" sms_count="1">201</msg>
            <msg sms_id="1234568" sms_count="1">1</msg>
          </message>
          <z>dsad</z>
        </package>
         * Output array (like JSON)
        {
            "package": {
                "value": {
                    "message": {
                        "value": {
                            "msg": {
                                "value": [
                                    {
                                        "value": "201",
                                        "_attributes_": {
                                            "id": "1234",
                                            "sms_id": "0",
                                            "sms_count": "1"
                                        },
                                        "_multi_": false
                                    },
                                    {
                                        "value": "1",
                                        "_attributes_": {
                                            "sms_id": "1234568",
                                            "sms_count": "1"
                                        },
                                        "_multi_": false
                                    }
                                ],
                                "_attributes_": null,
                                "multi": true
                            }
                        },
                        "_attributes_": [],
                        "_multi_": false
                    },
                    "z": {
                        "value": "dsad",
                        "_attributes_": [],
                        "_multi_": false
                    }
                },
                "_attributes_": [],
                "_multi_": false
            }
        }
         */

    /**
     * Обходчик для сбора информации о самом и вложеных элементов объекта SimpleXMLElement
     *
     * @param SimpleXMLElement $xmlObject
     *
     * @return array
     */
    $walker = function ($xmlObject) use (&$walker) {
        $key = $xmlObject->getName();

        $attributes = array();
        foreach ($xmlObject->attributes() as $attributeKey => $attributeValue) {
            $attributes[(string) $attributeKey] = (string) $attributeValue;
            unset($attributeKey);
            unset($attributeValue);
        }

        $childrenKeys = array();
        $childrenValues = array();
        $children = array();
        foreach ($xmlObject->children() as $child) {
            $temp = $walker($child);
            unset($child);
            $childrenKeys[] = $temp["key"];
            $childrenValues[] = $temp["element"];
            unset($temp);
        }

        if (count(array_unique($childrenKeys)) === count($childrenKeys)) {
            foreach ($childrenValues as $index => $childrenValue) {
                $children[$childrenKeys[$index]] = $childrenValue;
                unset($index);
                unset($childrenValue);
            }
        } else {
            $children = array(
                array_unique($childrenKeys)[0] => array(
                    "value"        => $childrenValues,
                    "_attributes_" => null,
                    "multi"        => true,
                ),
            );
        }

        if (count($children) === 0) {
            $children = (string) $xmlObject;
        }

        $xmlArray = array(
            "key"     => $key,
            "element" => array(
                "value"        => $children,
                "_attributes_" => $attributes,
                "_multi_"      => false,
            ),
        );

        return $xmlArray;
    };
    $key = $xmlObject->getName();
    $multi = false;

    $attributes = array();
    foreach ($xmlObject->attributes() as $attributeKey => $attributeValue) {
        $attributes[(string) $attributeKey] = (string) $attributeValue;
        unset($attributeKey);
        unset($attributeValue);
    }

    $childrenKeys = array();
    $childrenValues = array();
    $children = array();
    foreach ($xmlObject->children() as $child) {
        $temp = $walker($child);
        unset($child);
        $childrenKeys[] = $temp["key"];
        $childrenValues[] = $temp["element"];
        unset($temp);
    }
    if (count(array_unique($childrenKeys)) === count($childrenKeys)) {
        foreach ($childrenValues as $index => $childrenValue) {
            $children[$childrenKeys[$index]] = $childrenValue;
            unset($index);
            unset($childrenValue);
        }
    } else {
        $children = array(
            array_unique($childrenKeys)[0] => array(
                "value"        => $childrenValues,
                "_attributes_" => null,
                "multi"        => true,
            ),
        );
    }

    if (count($children) === 0) {
        $children = (string) $xmlObject;
    }

    $xmlArray = array(
        $key => array(
            "value"        => $children,
            "_attributes_" => $attributes,
            "_multi_"      => $multi,
        ),
    );

    return $xmlArray;
}


/*
 "client_id"    => $clientID,
 "name"         => $categoryName,
 "parent"       => $categoryParent,
 "uid"          => $categoryUID,
 "is_activated" => 1,
 "parent_uid"   => $categoryParentUID,
 "goods"        => [],
*/

function createTree($categories)
{
    $tree = [];

    foreach ($categories as $category) {
        if (empty($category["parent_uid"])) {
            $tree[] = $category;
            unset($category);
        }
    }

    // уровень вложенности 2
    foreach ($tree as &$itemTree) {
        foreach ($categories as $category) {
            /* if(!empty($category["parent_uid"])) {
                 print_r($itemTree);
                 print_r($category);
                 echo "\n";
                 echo "tree:\n";
                 print_r($itemTree["uid"]);
                 echo "\n category";
                 print_r($category["parent_uid"]);
                 exit();
             }*/
            if ($itemTree["uid"] == $category["parent_uid"]) {
                $itemTree["categories"] = $category;
                unset($category);
            }
        }
    }

    return $tree;
}

function buildTree(&$categories, $parentUID = '')
{
    $tree = [];

    foreach ($categories as &$category) {
        if ($category["parent_uid"] == $parentUID) {
            $children = buildTree($categories, $category["uid"]);
            if ($children) {
                $category["categories"] = $children;
            }
            //$tree[$category["uid"]] = $category;
            $tree[] = $category;
            unset($category);
        }
    }

    return $tree;
}

function makeTree(&$categories, $parentUID = '')
{
    // будем строить новый массив-дерево
    $tree = [];
    foreach ($categories as $key => $category) {
        /* проверяем, относится ли родитель элемента к самому
        верхнему уровню и не ссылается ли на самого себя */
        if ($category["parent_uid"] == $parentUID && $category["uid"] != $category["parent_uid"]) {
            // удаляем этот элемент из общего массива
            unset($categories[$key]);
            $tree[] = [
                // однако сохраним его в дереве
                $key         => $category,
                /* пробежим еще раз, но с уже
                меньшим числом элементов */
                "categories" => makeTree($items, $category["uid"]),
            ];
        }
    }

    return $tree;
}

/*$data = '{"goods": [{"uid": "4b7f754f-0b80-48e7-88d3-d385ee1eff29", "code": "6", "name": "тетрадь студенческая 64 листа", "price": 34, "parent": "", "price_out": 34, "description": ""}, {"uid": "515bc2ea-9cc6-48eb-8f83-eef1acd552c6", "name": "теефон", "price": 1000, "parent": "", "price_out": 1000, "description": ""}, {"uid": "0357cb2d-3321-4431-8a22-9d63b1e0894f", "code": "7", "name": "Булка с мясом", "price": 500, "parent": "", "price_out": 500, "description": ""}, {"uid": "f27004b4-b169-4249-ad0c-d08c5bc87d65", "code": "5", "name": "Карандаш простой ББ", "price": 6, "parent": "", "price_out": 6, "description": ""}, {"uid": "fff7e36f-7322-41a2-989b-7db65a1f0871", "code": "4", "name": "ручка красная гелевая", "price": 40, "parent": "", "price_out": 40, "description": ""}, {"uid": "0f5f1431-e53c-47f0-8e28-4225ca7c0717", "code": "22", "name": "!мой большой товар", "price": 1000, "parent": "", "price_out": 1000, "description": ""}, {"uid": "51801880-1fb0-4844-b996-e9d5594f14c4", "code": "23", "name": "!весовой товар", "price": 1000, "parent": "", "price_out": 1000, "description": ""}, {"uid": "cdc7c278-09a2-4731-b42c-c1277313246e", "code": "3", "name": "карта обыкновенная", "price": 400, "parent": "", "price_out": 400, "description": ""}, {"uid": "0e853c3a-94b5-414c-850c-8977267f10f4", "code": "1", "name": "тестовый товар 1", "price": 800, "parent": "", "price_out": 800, "description": ""}], "categories": [{"uid": "d962ada6-ad7e-4591-a1d8-c38f5d4bda86", "code": "9", "name": "группа2", "goods": [{"uid": "73448bf2-fb21-4489-8910-427729324265", "code": "17", "name": "второй товар группы 2", "price": 2, "parent": "d962ada6-ad7e-4591-a1d8-c38f5d4bda86", "price_out": 2, "description": ""}, {"uid": "81640528-b7a8-470e-a4ec-1d66482eed39", "code": "16", "name": "товар группы 2", "price": 22, "parent": "d962ada6-ad7e-4591-a1d8-c38f5d4bda86", "price_out": 22, "description": ""}], "parent": "", "categories": [{"uid": "e4165804-f064-4ed5-bc64-d38248236334", "code": "11", "name": "подгруппа2", "goods": [{"uid": "2a296e0c-12d6-477c-a4fe-6dcf95bf8d0b", "code": "15", "name": "второй товар подгруппы 2", "price": 2, "parent": "e4165804-f064-4ed5-bc64-d38248236334", "price_out": 2, "description": ""}, {"uid": "2ad8a2a8-b1e7-4621-bb97-8ab56d2a44a0", "code": "14", "name": "товар подгруппы 2", "price": 22, "parent": "e4165804-f064-4ed5-bc64-d38248236334", "price_out": 22, "description": ""}], "parent": "d962ada6-ad7e-4591-a1d8-c38f5d4bda86", "categories": [{"uid": "684dc76f-9291-4d51-a834-5cad75fcec0b", "code": "18", "name": "подгруппа подгруппы2", "goods": [{"uid": "2291bc0a-b863-4e5e-8b02-a2f2051c85bd", "code": "21", "name": "еще один самый последний в иерархии товар", "price": 0, "parent": "684dc76f-9291-4d51-a834-5cad75fcec0b", "price_out": 0, "description": ""}, {"uid": "9450cb36-a7cb-4927-890e-e7d4c9aa35e7", "code": "19", "name": "последний в иерархии товар", "price": 0, "parent": "684dc76f-9291-4d51-a834-5cad75fcec0b", "price_out": 0, "description": ""}], "parent": "e4165804-f064-4ed5-bc64-d38248236334", "categories": [], "description": "Категория подгруппа подгруппы2"}], "description": "Категория подгруппа2"}], "description": "Категория группа2"}, {"uid": "00dd7bf5-204a-450c-a451-3ac89181c05e", "code": "8", "name": "группа 1", "goods": [{"uid": "454d1283-0484-46b9-9434-2d2a28ca01d8", "code": "12", "name": "товар группы1", "price": 1, "parent": "00dd7bf5-204a-450c-a451-3ac89181c05e", "price_out": 1, "description": ""}], "parent": "", "categories": [{"uid": "46327fba-0b18-4b55-888a-8259a98c7c7d", "code": "20", "name": "еще одна подгруппа1", "goods": [], "parent": "00dd7bf5-204a-450c-a451-3ac89181c05e", "categories": [], "description": "Категория еще одна подгруппа1"}, {"uid": "75814b8a-1c4c-49d2-8247-bf85aa592a52", "code": "10", "name": "подгруппа1", "goods": [{"uid": "05affe2f-8c46-4da0-a9d1-f1f8ea6221c8", "code": "13", "name": "товар подгруппы 1", "price": 11, "parent": "75814b8a-1c4c-49d2-8247-bf85aa592a52", "price_out": 11, "description": ""}], "parent": "00dd7bf5-204a-450c-a451-3ac89181c05e", "categories": [], "description": "Категория подгруппа1"}], "description": "Категория группа 1"}]}';

$json = json_decode($data,  JSON_PRETTY_PRINT);

print_r($json);
exit();*/

// 780
$clientID = 4;
$fileXML = "fileXML.xml";

$goodsCategory = ORM::forTable("goods_categories")
    ->where([
        "client_id" => $clientID,
    ])->findArray();

$xml = new XMLReader();
$xml->open($fileXML);

$tag = "Объект";
//$tag = "ПравилаОбмена";

$categories = [];

$categories = $goodsCategory;

$goods = [];

while ($xml->read() && $xml->name != $tag) {
    ;
}

while ($xml->name == $tag) {
    $element = new SimpleXMLElement($xml->readOuterXML());

    $attributes = $element->attributes();

    $type = $attributes["Тип"];

    if ($type == "СправочникСсылка.Номенклатура") {
        /*
           Cсылка
                Cвойство[0] - goodUID
                Cвойство[1] - goodCode
                Свойство[2] - Принадлежность какой-то группе (-)
           Свойство
                [0] - Артикул товара
                [1] - Ссылка на категорию товара
                    Свойство[0] - categoryUID
                    Cвойство[1] - categoryName
                    Cвойство[2] - Принадлежность какой-то группе (-)
                [2] - Единица измерения товара
                    Свойство[0] - uid единицы
                    Cвойство[1] - код единицы измерения
                [3] - Полное наименование товара (goodName)
                [4] - Описание товара
                [5] - Cтавка НДС (-)
                [6] - Наименование категории товара
                [7] - Сокращённое наименование товара (-)
                [8] - Пометка для удаления (-)
                [9] - Информация о родителе чего-то
                     Свойство[0] - parentUID
                     Свойство[1] - parentCode
                     Cвойство[2] - Принадлежность какой-то группе (-)
                [10] - Автоматическая скидка?? (Число) (-)
                [11] - Cхема скидок?? (Число) (-)
        */

        // Ссылка на товар
        $goodUID = $element->Ссылка->Свойство[0]->Значение;
        $goodCode = $element->Ссылка->Свойство[1]->Значение;

        $properties = $element->Свойство;

        // Свойства товара
        foreach ($properties as $property) {
            $attributeName = $property->attributes()->Имя;

            switch ($attributeName) {
                case "Артикул": {
                    $goodArticle = $property->Значение ?? '';
                }
                    break;
                case "ВидНоменклатуры" : {
                    $categoryUID = $property->Ссылка->Свойство[0]->Значение ?? '';
                    $categoryName = $property->Ссылка->Свойство[1]->Значение ?? '';
                }
                    break;
                case "Наименование" : {
                    $goodName = $property->Значение ?? '';
                }
                    break;
                case "Описание" : {
                    $goodDescription = $property->Значение ?? '';
                }
                    break;
                case "Родитель" : {
                    $categoryParentUID = $property->Ссылка->Свойство[0]->Значение ?? '';
                    $categoryParent = $property->Ссылка->Свойство[1]->Значение ?? 0;
                }
                    break;
            }
        }

        $categoryUID = strval($categoryUID);
        $categoryName = strval($categoryName);
        $categoryParent = intval($categoryParent);
        $categoryParentUID = strval($categoryParentUID);
        $goodName = strval($goodName);
        $goodArticle = strval($goodArticle);
        $goodDescription = strval($goodDescription);
        $goodCode = strval($goodCode);
        $goodUID = strval($goodUID);

        $flag = true;

        foreach ($categories as $category) {
            if ($category["uid"] == $categoryUID) {
                $flag = false;
            }
        }

        // если категория не существует
        if ($flag) {
            $category = [
                "client_id"    => $clientID,
                "name"         => $categoryName,
                "parent"       => $categoryParent,
                "uid"          => $categoryUID,
                "is_activated" => 1,
                "parent_uid"   => $categoryParentUID,
                "goods"        => [],
            ];
            $categories[] = $category;
        }

        // uid = uid_1c
        $good = [
            "client_id"    => $clientID,
            "code"         => $goodCode,
            "name"         => $goodName,
            "article"      => $goodArticle,
            "price"        => 0,
            "description"  => $goodDescription,
            "price_out"    => 0,
            "uid"          => $goodUID,
            "is_activated" => 1,
            "category_uid" => $categoryUID,
        ];
        if (empty($categoryUID)) {
            $goods["root"] = $good;
        } else {
            $goods[$categoryUID][] = $good;
        }

        /* $category["goods"] = $goods[$categoryUID];
         print_r($category);
         print_r($goods[$categoryUID]);
         exit();*/

        /*$goodsCategory = ORM::forTable("goods_categories")
            ->where([
                "client_id" => $clientID,
                "uid"   => $categoryUID,
            ])->findOne();
        if (empty($goodsCategory)) {
            $goodsCategory = ORM::forTable("goods_categories")->create();
            $goodsCategory->set([
                "client_id" => $clientID,
                "name" => $categoryName,
                "parent" => $categoryParent,
                "description" => "Категория " . $categoryName,
                "uid" => $categoryUID,
                "is_activated" => 1,
                "parent_uid" => $categoryParentUID
            ]);
            $goodsCategory->save();
            if(empty($goodsCategory)) {
                throw new OrlanException("Ошибка сохранения категории товара");
            }
        }

        $good = ORM::forTable("goods")->create();
        $good->set([
            "client_id" => $clientID,
            "category_id"   => $goodsCategory["id"],
            "code"   => $goodCode,
            "name"   => $goodName,
            "article"   => $goodArticle,
            "price"   => 0,
            "description"   => $goodDescription,
            "price_out"   => 0,
            "uid_1c"      => $goodUID,
            "is_activated" => 1
        ]);
        $good->save();
        if (empty($good)) {
            throw new OrlanException("Ошибка сохранения товара");
        }*/
    }

    $xml->next($tag);
    unset($element);
}

$xml->close();

foreach ($categories as &$category) {
    if (!empty($goods[$category["uid"]])) {
        $category["goods"] = $goods[$category["uid"]];
        unset($goods[$category["uid"]]);
    }
}

print_r("Товары в категориях\n");

// построить дерево категорий
$treeCategories = buildTree($categories);
//$treeCategories = makeTree($categories);
//$treeCategories = createTree($categories);

print_r("Построили дерево категорий\n");

$data = [
    "categories" => $treeCategories,
    "goods"      => $goods["root"] ?? [],
];

$synchronization = new Synchronization($clientID, $data);
$synchronization->nomenclature();


