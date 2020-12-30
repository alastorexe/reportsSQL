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

$clientID = 4;
$fileXML = "fileXML.xml";

if (false) {

    $fullLoad = false;
    $PartLoad = false;
    $JSONLoad = false;
    $parseXML = false;

    if ($fullLoad) {
        echo "start\n";
        $xml = simplexml_load_file($fileXML);
        if ($xml === false) {
            throw new OrlanException("Не удалось разобрать файл");
        }
        echo "load complete\n";
        echo "parse start\n";
        //$answer = _parseXML($xml);
        echo "parse finish\n";
        echo "parse json start\n";
        $json = json_encode($xml, JSON_UNESCAPED_UNICODE);
        echo "parse json finish\n";
        echo "file start\n";
        file_put_contents("JSON_data.json", $json, FILE_APPEND);
        echo "file finish\n";
    }

    if ($PartLoad) {
        $xml = new XMLReader();
        $xml->open($fileXML);

        $tag = "Объект";
        //$tag = "ПравилаОбмена";

        while ($xml->read() && $xml->name != $tag) {
            ;
        }

        while ($xml->name == $tag) {
            $element = new SimpleXMLElement($xml->readOuterXML());

            $json = json_encode($element, JSON_UNESCAPED_UNICODE);
            $json = substr($json, 1);
            $json = substr($json, 0, -1);
            $json = '"' . "{$tag}" . '"' . " : {" . $json . "},";

            file_put_contents("JSON_data.json", $json, FILE_APPEND);

            $xml->next($tag);
            unset($element);
        }

        $xml->close();
    }

    if ($JSONLoad) {
        echo "start\n";
        $data = file_get_contents($fileJSON);
        echo "load complete\n";
        echo "parse start\n";
        $json = json_decode($data, JSON_UNESCAPED_UNICODE);
        echo "parse finish\n";
    }

    if ($parseXML) {
        $xml = new XMLReader();
        $xml->open($fileXML);

        $tag = "Объект";
        //$tag = "ПравилаОбмена";

        while ($xml->read() && $xml->name != $tag) {
            ;
        }

        while ($xml->name == $tag) {
            $element = new SimpleXMLElement($xml->readOuterXML());

            $attributes = $element->attributes();

            /*
                print_r("parse _xml start\n");
                $dataXML = _parseXML($element);
                print_r("parse _xml finish\n");

                $typeData = $dataXML["Объект"]["_attributes_"];

                $type = $typeData["Тип"];*/

            $type = $attributes["Тип"];

            if ($type == "СправочникСсылка.Номенклатура") {

                $good = ORM::forTable("goods")->create();
                $goodsCategory = ORM::forTable("goods_categories")->create();

                /* $goodUID = $dataXML["Объект"]["value"]["Ссылка"]["value"][0]["value"]["Свойство"]["value"][0]["value"]["Значение"]["value"];
                 $goodCode = $dataXML["Объект"]["value"]["Ссылка"]["value"][0]["value"]["Свойство"]["value"][1]["value"]["Значение"]["value"];
                 $goodName = $dataXML["Объект"]["value"]["Ссылка"]["value"][6]["value"]["Значение"]["value"];

                 $categoryUID = $dataXML["Объект"]["value"]["Ссылка"]["value"][2]["value"]["Ссылка"]["value"]["Свойство"]["value"][0]["value"]["Значение"]["value"];
                 $categoryName = $dataXML["Объект"]["value"]["Ссылка"]["value"][2]["value"]["Ссылка"]["value"]["Свойство"]["value"][1]["value"]["Значение"]["value"];

                 print_r($goodUID);
                 echo "\n";
                 print_r($goodCode);
                 echo "\n";
                 print_r($goodName);
                 echo "\n";
                 print_r($categoryUID);
                 echo "\n";
                 print_r($categoryName);
                 echo "\n";*/


                $goodUID = $element->Ссылка->Свойство[0]->Значение;
                $goodCode = $element->Ссылка->Свойство[1]->Значение;
                $goodArticle = $element->Свойство[0]->Значение ?? '';
                $goodName = $element->Свойство[3]->Значение ?? '';
                $goodDescription = $element->Свойство[4]->Значение ?? '';

                if ($goodDescription) {
                    print_r($element);
                    exit();
                }

                /*
                 * Cсылка
                 *      Cвойство[0] - goodUID
                 *      Cвойство[1] - goodCode
                 *      Свойство[2] - Принадлежность какой-то группе (-)
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


                $categoryUID = $element->Свойство[1]->Ссылка->Свойство[0]->Значение;
                $categoryName = $element->Свойство[1]->Ссылка->Свойство[1]->Значение;
                $categoryParentUID = $element->Свойство[7]->Ссылка->Свойство[0]->Значение ?? '';
                $categoryParent = $element->Свойство[7]->Ссылка->Свойство[1]->Значение ?? 0;

                print_r($goodUID);
                echo "\n";
                print_r($goodCode);
                echo "\n";
                print_r($goodArticle);
                echo "\n";
                print_r($goodName);
                echo "\n";
                print_r($goodDescription);
                echo "\n";
                print_r($categoryUID);
                echo "\n";
                print_r($categoryName);
                echo "\n";
                print_r($categoryParentUID);
                echo "\n";
                print_r($categoryParent);
                echo "\n";

                /*$goodsCategory->set([
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

                $good->set([
                    "client_id" => $clientID,
                    "user_id"   => 1,
                    "category_id"   => 1,
                    "code"   => $goodCode,
                    "name"   => $goodName,
                    "article"   => $goodArticle,
                    "price"   => 1,
                    "description"   => $goodDescription,
                    "price_out"   => 1
                ]);
                $good->save();
                if (empty($good)) {
                    throw new OrlanException("Ошибка сохранения товара");
                }*/
            }

            if (false) {
                $types = [
                    "СправочникСсылка.Номенклатура",
                    "СправочникСсылка.ВидыНоменклатуры",
                    "СправочникСсылка.УпаковкиНоменклатуры",
                    "CправочникСсылка.ХарактеристикиНоменклатуры",
                    "CправочникСсылка.СегментыНоменклатуры",
                    "СправочникСсылка.СерииНоменклатуры",
                    "СправочникСсылка.НоменклатураПрисоединённыеФайлы",
                ];

                unset($typeData);
                unset($dataXML);

                if (in_array($type, $types)) {
                    print_r("json ecncode start\n");
                    $json = json_encode($element, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
                    $json = substr($json, 1);
                    $json = substr($json, 0, -1);
                    $json = '"' . "{$tag}" . '"' . " : {" . $json . "},\n";
                    print_r("json ecncode finish\n");

                    switch ($type) {
                        case "СправочникСсылка.Номенклатура": {
                            file_put_contents("nomenclature_data.json", $json, FILE_APPEND);
                        }
                            break;
                        case "СправочникСсылка.ВидыНоменклатуры" : {
                            file_put_contents("type_nomenclature_data.json", $json, FILE_APPEND);
                        }
                            break;

                        case "СправочникСсылка.УпаковкиНоменклатуры" : {
                            file_put_contents("packaging_nomenclature_data.json", $json, FILE_APPEND);
                        }
                            break;

                        case "CправочникСсылка.ХарактеристикиНоменклатуры" : {
                            file_put_contents("specifications_nomenclature_data.json", $json, FILE_APPEND);
                        }
                            break;

                        case "CправочникСсылка.СегментыНоменклатуры" : {
                            file_put_contents("segments_nomenclature_data.json", $json, FILE_APPEND);
                        }
                            break;

                        case "СправочникСсылка.СерииНоменклатуры" : {
                            file_put_contents("series_nomenclature_data.json", $json, FILE_APPEND);
                        }
                            break;
                        case "СправочникСсылка.НоменклатураПрисоединённыеФайлы" : {
                            file_put_contents("files_nomenclature_data.json", $json, FILE_APPEND);
                        }
                            break;
                    }

                    /*  print_r("ТИП:");
                      print_r($typeData);

                      print_r("\n\n");

                      print_r($dataXML);
                      print_r("\n\n");*/

                    /*$json = json_encode($element, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
                    file_put_contents("json_data.json", $json, FILE_APPEND);*/
                }

            }

            $xml->next($tag);
            unset($element);
        }

        $fileContent = file_get_contents($fileNomenclature);
        $fileContent = substr($fileContent, 0, -1);

        file_put_contents($fileNomenclature, "{\n" . $fileContent);
        file_put_contents($fileNomenclature, "\n}", FILE_APPEND);

        $xml->close();
    }
}

$clientID = 780;
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

/*foreach ($categories as &$category) {
    if (!empty($goods[$category["uid"]])) {
        $category["goods"] = $goods[$category["uid"]];
        unset($goods[$category["uid"]]);
    }
}*/

// построить дерево категорий
$treeCategories = buildTree($categories);
//$treeCategories = makeTree($categories);
//$treeCategories = createTree($categories);

print_r($treeCategories);
exit();

$data = [
    "categories" => $treeCategories,
    "goods"      => $goods["root"] ?? [],
];

$synchronization = new Synchronization($clientID, $data);
$synchronization->nomenclature();


