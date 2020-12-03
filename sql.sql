/*
Необходимо выгрузить номера карт, которые заправлялись с 01.11-30.11 от 16 заправок и более
( главное условие чтобы минимум в 1 чеке было от 1500 рублей на топливо и хот дог).

Нужны только номера карт
*/

SELECT
  cards.uid,
  count(DISTINCT orders.id) AS orders_count
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  INNER JOIN orders ON orders.card_id = cards.id
  INNER JOIN goods_incomes ON goods_incomes.order_id = orders.id
  INNER JOIN (
               SELECT orders.*
               FROM orders
               WHERE orders.client_id = 625
                     AND orders.id IN (
                 SELECT orders.id
                 FROM orders
                   INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 WHERE orders.client_id = 625
                       AND orders.from >= '2020-11-01'
                       AND orders.from <= '2020-11-30 23:59:59'
                       AND goods_incomes.goods_id IN (
                   1516847, 2305419, 3013460, 1516843, 1516845, 1516848, 2212948, 1516849, 1516851, 1518158, 2107476, 2528930
                 )
                       AND goods_incomes.goods_summary >= 1500
                 GROUP BY orders.id
               )
                     AND orders.id IN (
                 SELECT orders.id
                 FROM orders
                   INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                   INNER JOIN goods ON goods.id = goods_incomes.goods_id
                 WHERE orders.client_id = 625
                       AND orders.from >= '2020-11-01'
                       AND orders.from <= '2020-11-30 23:59:59'
                       AND goods.article IN (
                   '020816', '020822', '020821', '021451', '020812', '020819', '023933', '020818', '020813', '023934', '023979', '023889', '024524', '024531', '023892', '024533', '021648', '024535', '021630', '021626', '024537', '023888', '023893', '023891', '023894', '023895', '023607', '022951', '022952', '023890', '022954', '023109', '022417', '022416', '022785', '022786', '024689', '024523', '024526', '024527', '024528', '024529', '020740', '020741', '020596', '016517', '023606', '013474', '009909', '022782', '020902', '023085', '022781', '017274', '023088', '013479', '020808', '020810', '020674', '024138', '021454', '022789', '022791', '022788', '024534', '024532', '024530', '024536', '024690', '024525', '022790', '022792', '022441', '022787', '022440'
                 )
                 GROUP BY orders.id
               )
             ) AS custom_orders ON custom_orders.card_id = cards.id
WHERE cards.client_id = 625
      AND goods_incomes.goods_id IN (
  1516847, 2305419, 3013460, 1516843, 1516845, 1516848, 2212948, 1516849, 1516851, 1518158, 2107476, 2528930
)
      AND orders.from >= '2020-11-01'
      AND orders.from <= '2020-11-30 23:59:59'
GROUP BY cards.id
HAVING orders_count >= 16;


/*Необходимо выгрузить отчет данных по клиентам, которые последнюю покупку делали до 01.11.2020

1) Номер карты, ФИО, номер телефона, согласие на получение уведомлений ( да/нет), Дата последней покупи*/

SELECT
  cards.uid,
  profiles.name,
  profiles.phone,
  profiles.send_sms,
  orders.from
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  INNER JOIN orders ON orders.card_id = cards.id
WHERE cards.client_id = 1008
      AND orders.from <= '2020-11-01 23:59:59'
GROUP BY cards.id
ORDER BY orders.from DESC;

/*
Необходимо выгрузить номера карт и дату последней покупки в таблицу Excel, условия следующие:

Клиенты, которые не пили кофе ( артикулы во вложении) с 1.01.20 по 24.11.20 включительно и имеют мобильное приложение.
*/

SELECT
  cards.uid,
  MAX(orders.from)
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  INNER JOIN orders ON orders.card_id = cards.id
  INNER JOIN (SELECT profile_id
              FROM profiles_worksheets
              WHERE worksheet_id = 207 AND value = '1') AS pw ON pw.profile_id = profiles.id
WHERE cards.client_id = 625
      AND orders.from >= '2020-01-01'
      AND orders.from <= '2020-11-24 23:59:59'
      AND cards.id NOT IN (
  SELECT cards.id
  FROM cards
    INNER JOIN profiles ON profiles.id = cards.profile_id
    INNER JOIN orders ON orders.card_id = cards.id
    INNER JOIN goods_incomes ON goods_incomes.order_id = orders.id
  WHERE cards.client_id = 625
        AND orders.from >= '2020-01-01'
        AND orders.from <= '2020-11-24 23:59:59'
        AND goods_incomes.goods_id IN (
    1517225, 1518183, 1525781, 1516892, 1518896, 1519651, 1517452, 1517453, 1517991, 1517454, 1516863, 1516866, 1516865, 1516867, 1516868, 1516869, 1516871, 1516881, 1518888, 1519652, 1517450, 1517451, 1517456, 1516882, 1519344, 2441615, 1519361, 1519374, 1519432, 1519434, 1519433, 1519430, 1519431, 1519435, 1519439, 1519436, 1518895, 1519650, 1516890, 1516496, 1516498, 1516499, 1518893, 1516888, 1519364, 1518889, 1516884, 1518892, 1519649, 2193061, 1516886, 2201956, 1516885, 1516887, 1518891, 1518378, 1518894, 1516889, 1516883, 1522602, 1522603, 1522604, 1522599, 1522601, 1519354, 1519129, 1519128, 1517530, 1525200, 1516891, 1519376, 1519375, 1519352, 1519372, 1519351, 1519373, 1519378, 1519348, 1519377, 1519346, 1519349, 1519370, 1517238, 1517239, 1519103, 1519104, 1519347, 1519345, 1517241, 1517240, 1521330, 1521332, 1521331, 1524979, 1524980, 1519355, 1524887, 1524877, 1524880, 1524886, 1524878, 1524881, 1517975, 1517959, 1517964, 1517965, 1517960, 1517976, 1524896, 1524889, 1524892, 1517966, 1517957, 1517973, 1517974, 1517958, 1517967, 1524893, 1524895, 1524888, 1524883, 1524884, 1517970, 1517971, 1524869, 1524867, 1524865, 1524866, 1524872, 1524870, 1517955, 1517949, 1517944, 1517956, 1517950, 1517945, 1524868, 1524871, 1517952, 1517953, 1517984, 1517985, 1517983, 1517982, 2100032, 2102346, 2100526, 2029017, 2029019, 2029018, 2029014, 2029013, 2029015, 2029016, 2029024, 2029026, 2029021, 2029027, 2029022, 2099946, 2099659, 2099388, 2100565, 2100122, 2099736, 2003949, 2101292, 2022138, 2099384, 2010210, 2099739, 2076155, 2087466, 2021077, 2087689, 2086283, 2022647, 2099521, 2095765, 2095867, 2086495, 2102053, 2102402, 2029020, 2029023, 2029025, 2029008, 2029009, 2029010, 2029012, 1518890, 2003890, 2073701, 2000073, 2080983, 2077750, 2027909, 2101879, 2003958, 2003969, 2010584, 2072975, 2028372, 2073586, 1999525, 2030387, 2030939, 2003884, 2099808, 1998867, 2100751, 2088373, 2100714, 2101812, 2097224, 2096576, 2095702, 2088350, 2029035, 2029036, 2010211, 2029034, 2099753, 2029031, 2029028, 2029030, 2029029, 2086199, 2086206, 2086091, 2095699, 2101073, 2096199, 2099741)
  GROUP BY cards.id
)
GROUP BY cards.id;

/* Нужно выбрать карты Светофор ( эти карты начинаются с цифр 220950000....) и выгрузить их в таблицу Excel, со следующими данными:

1) Номер карты
2) Дата привязки профиля к карте
3) Кол-во чеков за весь период
4)Дата последнего чека
5)Номер телефона
6) Общая сумма начисленных бонусов за весь период
7) Общая сумма потраченных бонусов за весь период

SQL + скрипт
*/

SELECT
  cards.uid,
  hpc.created_at,
  count(DISTINCT orders.id),
  max(orders.from),
  profiles.phone,
  sum(goods_incomes.bonus_add),
  sum(goods_incomes.bonus_remove)
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  LEFT OUTER JOIN orders ON orders.card_id = cards.id
  LEFT OUTER JOIN goods_incomes ON goods_incomes.order_id = orders.id
  LEFT OUTER JOIN (
                    SELECT *
                    FROM history_profiles_change
                    WHERE client_id = 625 AND is_creation = TRUE
                  ) AS hpc ON hpc.profile_id = profiles.id
WHERE cards.client_id = 625
      AND cards.uid LIKE '220950000%'
GROUP BY cards.id;


/*
1008
Необходимо выгрузить данные в 2 таблицы Excel:
Нужно выбрать 1000 клиентов сначала за октябрь ( период 01.10.20-31.10.20) ,
затем за ноябрь ( 01.11.20-30.11.20) .
Сформировать список клиентов у кого самая большая сумма покупок за эти периоды:

1) Номер карты
2) ФИО
3) Номер телефона
4) Общая  сумма продаж за заданные периоды.
выбрать 1000 клиентов у которых сумма наибольшая
*/

SELECT
  cards.uid,
  profiles.name,
  profiles.phone,
  SUM(orders.summary) AS sum_orders
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  INNER JOIN orders ON orders.card_id = cards.id
WHERE cards.client_id = 1008
      AND orders.from >= '2020-11-01'
      AND orders.from <= '2020-11-30 23:59:59'
GROUP BY cards.id
ORDER BY sum_orders DESC
LIMIT 1000;


/*
Необходимо загрузить в "Списки клиентов" 2 группы карт.

1) Название списка "Не покупали 2 недели"
2) Название списка " Не покупали месяц"
*/

SELECT profiles.id
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
WHERE cards.client_id = 1008
      AND cards.uid IN (
  '79859944731', '79015019844', '79131456948', '79273250575', '79859659620', '79011885227', '79652469945')
GROUP BY cards.id;

SELECT *
FROM buyer_lists
WHERE client_id = 1008;


/*Клиент, просит дополнить таблицу во вложении:

Описание:


Запрос выборка карт с параметрами

заправка на азс № 9, 8, 7, 6, 5, 4, 3, 24, 23, 21, 20, 10, 19, 18, 17, 16, 15, 14, 13, 1
1 карта активная (3-5 заправок на станции за последний месяц 01.11 - 30.11)
1 карта не активная (после 01.11 отсутствовала совсем, но была заправка в период 01.10 по31.10)
по видам топлива АИ-92-К5, АИ-95-К5, АИ-95-К5 GT, ДТ-3-К5*/

SELECT
  cards.uid,
  count(DISTINCT orders.id) AS count_orders
FROM cards
  INNER JOIN orders ON orders.card_id = cards.id
  INNER JOIN (
               SELECT orders.*
               FROM orders
               WHERE orders.client_id = 625
                     AND orders.id IN (
                 SELECT orders.id
                 FROM orders
                 WHERE orders.client_id = 625
                       AND orders.from >= '2020-11-01'
                       AND orders.from <= '2020-11-30 23:59:59'
                       AND orders.shop_id IN (
                   2291, 2297, 2311, 2312, 2304, 2303, 2287, 2286, 2300, 2301, 2302, 2481, 2479, 2315, 2316, 2317, 2318, 2289, 2319, 2320, 2254, 2292, 2277, 2278, 2279, 2280, 3309, 2288, 2290, 2255, 2256, 2283, 2284, 2285, 2564, 2253, 2299
                 )
                 GROUP BY orders.id
               )
                     AND orders.id IN (
                 SELECT orders.id
                 FROM orders
                   INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                   INNER JOIN goods ON goods.id = goods_incomes.goods_id
                 WHERE orders.client_id = 625
                       AND orders.from >= '2020-11-01'
                       AND orders.from <= '2020-11-30 23:59:59'
                       AND goods.article IN (
                   'ДТ-З-К5',
                   'АИ-95-К5',
                   'АИ-95-К5',
                   'АИ-95-К5 GT',
                   'АИ-95-К5 GT',
                   'АИ-92-К5',
                   'АИ-92-К5'
                 )
                 GROUP BY orders.id
               )
                     AND orders.from >= '2020-11-01'
                     AND orders.from <= '2020-11-30 23:59:59'
             ) AS custom_orders ON custom_orders.card_id = cards.id
WHERE cards.client_id = 625
      AND orders.shop_id IN (
  2291, 2297, 2311, 2312, 2304, 2303, 2287, 2286, 2300, 2301, 2302, 2481, 2479, 2315, 2316, 2317, 2318, 2289, 2319, 2320, 2254, 2292, 2277, 2278, 2279, 2280, 3309, 2288, 2290, 2255, 2256, 2283, 2284, 2285, 2564, 2253, 2299
)
      AND orders.from >= '2020-11-01'
      AND orders.from <= '2020-11-30 23:59:59'
GROUP BY cards.id
HAVING count_orders >= 3
       AND count_orders <= 5;

/*
9 - 2291
8 - 2297
7 - 2311, 2312
6 - 2304, 2303
5 - 2287, 2286
4 - 2300
3 - 2301, 2302
24 - 2481, 2479
23 - 2315, 2316, 2317, 2318
21 - 2289
20 - 2319, 2320
10 - 2254
19 - 2292
18 - 2277, 2278, 2279, 2280, 3309
17 - 2288
16 - 2290
15 - 2255, 2256
14 - 2283, 2284, 2285, 2564
13 - 2253
1 - 2299

*/

SELECT
  cards.uid,
  count(DISTINCT orders.id) AS count_orders,
  MAX(orders.`from`) AS max_date
FROM cards
  INNER JOIN orders ON orders.card_id = cards.id
  INNER JOIN (
               SELECT orders.*
               FROM orders
               WHERE orders.client_id = 625
                     AND orders.id IN (
                 SELECT orders.id
                 FROM orders
                 WHERE orders.client_id = 625
                       AND orders.from >= '2020-10-01'
                       AND orders.from <= '2020-12-03 23:59:59'
                       AND orders.shop_id IN (
                   2291, 2297, 2311, 2312, 2304, 2303, 2287, 2286, 2300, 2301, 2302, 2481, 2479, 2315, 2316, 2317, 2318, 2289, 2319, 2320, 2254, 2292, 2277, 2278, 2279, 2280, 3309, 2288, 2290, 2255, 2256, 2283, 2284, 2285, 2564, 2253, 2299
                 )
                 GROUP BY orders.id
               )
                     AND orders.id IN (
                 SELECT orders.id
                 FROM orders
                   INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                   INNER JOIN goods ON goods.id = goods_incomes.goods_id
                 WHERE orders.client_id = 625
                       AND orders.from >= '2020-10-01'
                       AND orders.from <= '2020-12-03 23:59:59'
                       AND goods.article IN (
                   'ДТ-З-К5',
                   'АИ-95-К5',
                   'АИ-95-К5',
                   'АИ-95-К5 GT',
                   'АИ-95-К5 GT',
                   'АИ-92-К5',
                   'АИ-92-К5'
                 )
                 GROUP BY orders.id
               )
                     AND orders.from >= '2020-10-01'
                     AND orders.from <= '2020-12-03 23:59:59'
             ) AS custom_orders ON custom_orders.card_id = cards.id
WHERE cards.client_id = 625
      AND orders.shop_id IN (
  2291, 2297, 2311, 2312, 2304, 2303, 2287, 2286, 2300, 2301, 2302, 2481, 2479, 2315, 2316, 2317, 2318, 2289, 2319, 2320, 2254, 2292, 2277, 2278, 2279, 2280, 3309, 2288, 2290, 2255, 2256, 2283, 2284, 2285, 2564, 2253, 2299
)
      AND orders.from >= '2020-10-01'
      AND orders.from <= '2020-12-03 23:59:59'
GROUP BY cards.id
HAVING max_date <= '2020-10-31 23:59:59'

