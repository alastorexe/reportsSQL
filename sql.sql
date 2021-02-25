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



/*
По приведенным ниже артикулам, необходимо выгрузить кол-во купленных чашек всего за период с 14.12-20.12

017811
017812
017813
017814
015912
016163
016172
016074
021662


Саша, по этим данным нужно выгрузить 51 неделю в понедельник.
*/


SELECT
  cup.article,
  count(cup.id)
FROM cards
  INNER JOIN (
               SELECT
                 orders.*,
                 goods.article
               FROM orders
                 INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 INNER JOIN goods ON goods.id = goods_incomes.goods_id
               WHERE orders.client_id = 625
                     AND orders.from >= '2020-12-21'
                     AND orders.from <= '2020-12-27 23:59:59'
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
             ) AS cup ON cup.card_id = cards.id
WHERE cards.client_id = 625
GROUP BY cup.article;


SELECT *
FROM cards
WHERE cards.client_id = 888
      AND cards.uid = '79171332415';

/*
Привязкать телефон к личному кабинету
*

select * from goods
where goods.client_id = 1004;

*/

/*
Декорадо 780
 */

SELECT *
FROM goods
WHERE goods.client_id = 780;

SELECT *
FROM goods_categories
WHERE client_id = 780;

/*3735*/

SELECT *
FROM bills
WHERE id = 3735;

UPDATE bills
SET bills.exported = 1
WHERE bills.id = 3735;


/*
У АЗС есть списки клиентов "Monopoly", "Monopoly2", 1ДТ_РОЗНИЦА".

С 26.11 у данных клиентов наложились программы лояльности ( действовала и скидочная и бонусная система" .

Вопрос: Можно у этих  клиентов с 26.11-25.12 списать все начисленные бонусы за этот период?
*/

/*
1616
1669
1661
*/

SELECT *
FROM buyer_lists
WHERE client_id = 625
      AND name = '1ДТ_РОЗНИЦА';

SELECT buyers_list.buyers
FROM buyers_list
WHERE buyer_list_id = 1661;

SELECT cards.id
FROM cards
  INNER JOIN profiles ON cards.id = profiles.card_id
WHERE cards.client_id = 625
      AND profile_id IN (123);


UPDATE balance_movements
SET balance_movements.end_date = NOW()
where balance_movements.card_id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1;

UPDATE cards
SET cards.next_recalc = NOW()
where cards.id in ();

SELECT
  cards.uid,
  cards.next_recalc,
  balance_movements.is_positive,
  balance_movements.from_date,
  balance_movements.end_date
FROM cards
  INNER JOIN balance_movements on cards.id = balance_movements.card_id
WHERE cards.client_id = 625
      AND cards.id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1
GROUP BY balance_movements.id;

SELECT
  cards.id,
  cards.uid,
  cards.balance,
  goods_incomes.bonus_add
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  LEFT OUTER JOIN orders ON orders.card_id = cards.id
  LEFT OUTER JOIN goods_incomes ON goods_incomes.order_id = orders.id
WHERE cards.client_id = 625
      AND cards.id in ()
      AND orders.`from` >= '2020.11.26'
      AND orders.`from` <= '2020.12.25 23:59:59'
      AND goods_incomes.bonus_add > 0
GROUP BY orders.id;


/*
По приведенным ниже артикулам, необходимо выгрузить кол-во купленных чашек всего за период с 14.12-20.12

017811
017812
017813
017814
015912
016163
016172
016074
021662


Саша, по этим данным нужно выгрузить 52 неделю в понедельник.
*/


SELECT
  cup.article,
  count(cup.id)
FROM cards
  INNER JOIN (
               SELECT
                 orders.*,
                 goods.article
               FROM orders
                 INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 INNER JOIN goods ON goods.id = goods_incomes.goods_id
               WHERE orders.client_id = 625
                     AND orders.from >= '2020-12-21'
                     AND orders.from <= '2020-12-27 23:59:59'
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
             ) AS cup ON cup.card_id = cards.id
WHERE cards.client_id = 625
GROUP BY cup.article;


/*
У АЗС есть списки клиентов "Monopoly", "Monopoly2", 1ДТ_РОЗНИЦА".

С 26.11 у данных клиентов наложились программы лояльности ( действовала и скидочная и бонусная система" .

Вопрос: Можно у этих  клиентов с 26.11-25.12 списать все начисленные бонусы за этот период?
*/

/*
1616
1669
1661
*/
UPDATE balance_movements
SET balance_movements.end_date = NOW()
where balance_movements.card_id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1;

UPDATE cards
SET cards.next_recalc = NOW()
where cards.id in ();

SELECT
  cards.uid,
  cards.next_recalc,
  balance_movements.is_positive,
  balance_movements.from_date,
  balance_movements.end_date
FROM cards
  INNER JOIN balance_movements on cards.id = balance_movements.card_id
WHERE cards.client_id = 625
      AND cards.id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1
GROUP BY balance_movements.id;

SELECT
  cards.id,
  cards.uid,
  cards.balance,
  goods_incomes.bonus_add
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  LEFT OUTER JOIN orders ON orders.card_id = cards.id
  LEFT OUTER JOIN goods_incomes ON goods_incomes.order_id = orders.id
WHERE cards.client_id = 625
      AND cards.id in ()
      AND orders.`from` >= '2020.11.26'
      AND orders.`from` <= '2020.12.25 23:59:59'
      AND goods_incomes.bonus_add > 0
GROUP BY orders.id;

/*
Необходимо выгрузить в таблицу excel клиентов, которые зарегистрировались с 7.10 -29.12:

1) Регион (название группы магазинов)
2) Магазин
3)ФИО
4)Номер телефона
5) Дата регистрации.

Регион можно посмотреть в структуре личного кабинета ( Отчеты-->Продажи-->Структура). Пример выгрузки во вложении
*/

SELECT
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
GROUP BY cards.id;


SELECT *
FROM cards
WHERE cards.client_id = 888
      AND cards.uid = '79171332415';

/*
Привязкать телефон к личному кабинету
*

select * from goods
where goods.client_id = 1004;

*/

/*
Декорадо 780
 */

SELECT *
FROM goods
WHERE goods.client_id = 780;

SELECT *
FROM goods_categories
WHERE client_id = 780;

/*3735*/

SELECT *
FROM bills
WHERE id = 3735;

UPDATE bills
SET bills.exported = 1
WHERE bills.id = 3735;


/*
У АЗС есть списки клиентов "Monopoly", "Monopoly2", 1ДТ_РОЗНИЦА".

С 26.11 у данных клиентов наложились программы лояльности ( действовала и скидочная и бонусная система" .

Вопрос: Можно у этих  клиентов с 26.11-25.12 списать все начисленные бонусы за этот период?
*/

/*
1616
1669
1661
*/

SELECT *
FROM buyer_lists
WHERE client_id = 625
      AND name = '1ДТ_РОЗНИЦА';

SELECT buyers_list.buyers
FROM buyers_list
WHERE buyer_list_id = 1661;

SELECT cards.id
FROM cards
  INNER JOIN profiles ON cards.id = profiles.card_id
WHERE cards.client_id = 625
      AND profile_id IN (123);


UPDATE balance_movements
SET balance_movements.end_date = NOW()
where balance_movements.card_id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1;

UPDATE cards
SET cards.next_recalc = NOW()
where cards.id in ();

SELECT
  cards.uid,
  cards.next_recalc,
  balance_movements.is_positive,
  balance_movements.from_date,
  balance_movements.end_date
FROM cards
  INNER JOIN balance_movements on cards.id = balance_movements.card_id
WHERE cards.client_id = 625
      AND cards.id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1
GROUP BY balance_movements.id;

SELECT
  cards.id,
  cards.uid,
  cards.balance,
  goods_incomes.bonus_add
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  LEFT OUTER JOIN orders ON orders.card_id = cards.id
  LEFT OUTER JOIN goods_incomes ON goods_incomes.order_id = orders.id
WHERE cards.client_id = 625
      AND cards.id in (123)
      AND orders.`from` >= '2020.11.26'
      AND orders.`from` <= '2020.12.25 23:59:59'
      AND goods_incomes.bonus_add > 0
GROUP BY orders.id;


/*
По приведенным ниже артикулам, необходимо выгрузить кол-во купленных чашек всего за период с 14.12-20.12

017811
017812
017813
017814
015912
016163
016172
016074
021662


Саша, по этим данным нужно выгрузить 51 неделю в понедельник.
*/


SELECT
  good.article,
  count(good.id)
FROM cards
  INNER JOIN (
               SELECT
                 orders.*,
                 goods.article
               FROM orders
                 INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 INNER JOIN goods ON goods.id = goods_incomes.goods_id
               WHERE orders.client_id = 625
                     AND orders.from >= '2020-12-21'
                     AND orders.from <= '2020-12-27 23:59:59'
                     AND goods.article IN (
                 '017811',
                 '017812',
                 '017813',
                 '008548',
                 '003223',
                 '017817',
                 '024528',
                 '025531',
                 '022783',
                 '020403',
                 '013919',
                 '013918'
               )
             ) AS good ON good.card_id = cards.id
WHERE cards.client_id = 625
GROUP BY good.article;


select * from goods_categories
where client_id = 625;


/*
Декорадо - 780
*/

SELECT * from goods_categories
where goods_categories.client_id = 4;

SELECT * from goods
where goods.client_id = 780;

select * from clients
where id = 4;


/*
Необходимо выгрузить в таблицу excel клиентов, которые зарегистрировались с 7.10 -29.12:

1) Регион (название группы магазинов)
2) Магазин
3)ФИО
4)Номер телефона
5) Дата регистрации.

Регион можно посмотреть в структуре личного кабинета ( Отчеты-->Продажи-->Структура). Пример выгрузки во вложении
*/

SELECT
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
GROUP BY cards.id;


select sale_general_report from reports_configurations
where client_id = 888;


select * from cards
  INNER JOIN profiles ON profiles.id = cards.profile_id

/*
Загрузить в список
*/

select profiles.id from cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
where cards.client_id = 625
AND cards.uid in ();


/*
Яндекс 0 баланс - 1926
*/
select * from buyer_lists
where buyer_lists.name = 'Яндекс 0 баланс';


select * from cards
where cards.uid = '221188221188';

select * from balance_movements
where card_id = 4778424;

select
  client_id,
  name,
  parent,
  description,
  uid,
  is_activated,
  parent_uid,
  accumulation_rate
from goods_categories
where client_id = 780;

SELECT *
FROM cards
WHERE cards.client_id = 888
      AND cards.uid = '79171332415';

/*
Привязкать телефон к личному кабинету
*

select * from goods
where goods.client_id = 1004;

*/

/*
Декорадо 780
 */

SELECT *
FROM goods
WHERE goods.client_id = 780;

SELECT *
FROM goods_categories
WHERE client_id = 780;

/*3735*/

SELECT *
FROM bills
WHERE id = 3735;

UPDATE bills
SET bills.exported = 1
WHERE bills.id = 3735;


/*
У АЗС есть списки клиентов "Monopoly", "Monopoly2", 1ДТ_РОЗНИЦА".

С 26.11 у данных клиентов наложились программы лояльности ( действовала и скидочная и бонусная система" .

Вопрос: Можно у этих  клиентов с 26.11-25.12 списать все начисленные бонусы за этот период?
*/

/*
1616
1669
1661
*/

SELECT *
FROM buyer_lists
WHERE client_id = 625
      AND name = '1ДТ_РОЗНИЦА';

SELECT buyers_list.buyers
FROM buyers_list
WHERE buyer_list_id = 1661;

SELECT cards.id
FROM cards
  INNER JOIN profiles ON cards.id = profiles.card_id
WHERE cards.client_id = 625
      AND profile_id IN (123);


UPDATE balance_movements
SET balance_movements.end_date = NOW()
where balance_movements.card_id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1;

UPDATE cards
SET cards.next_recalc = NOW()
where cards.id in ();

SELECT
  cards.uid,
  cards.next_recalc,
  balance_movements.is_positive,
  balance_movements.from_date,
  balance_movements.end_date
FROM cards
  INNER JOIN balance_movements on cards.id = balance_movements.card_id
WHERE cards.client_id = 625
      AND cards.id in ()
      AND balance_movements.from_date >= '2020.11.26'
      AND balance_movements.from_date <= '2020.12.25 23:59:59'
      AND balance_movements.is_positive = 1
GROUP BY balance_movements.id;

SELECT
  cards.id,
  cards.uid,
  cards.balance,
  goods_incomes.bonus_add
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
  LEFT OUTER JOIN orders ON orders.card_id = cards.id
  LEFT OUTER JOIN goods_incomes ON goods_incomes.order_id = orders.id
WHERE cards.client_id = 625
      AND cards.id in (123)
      AND orders.`from` >= '2020.11.26'
      AND orders.`from` <= '2020.12.25 23:59:59'
      AND goods_incomes.bonus_add > 0
GROUP BY orders.id;


/*
По приведенным ниже артикулам, необходимо выгрузить кол-во купленных чашек всего за период с 14.12-20.12

017811
017812
017813
017814
015912
016163
016172
016074
021662


Саша, по этим данным нужно выгрузить 51 неделю в понедельник.
*/


SELECT
  good.article,
  count(good.id)
FROM cards
  INNER JOIN (
               SELECT
                 orders.*,
                 goods.article
               FROM orders
                 INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 INNER JOIN goods ON goods.id = goods_incomes.goods_id
               WHERE orders.client_id = 625
                     AND orders.from >= '2021-01-04'
                     AND orders.from <= '2021-01-10 23:59:59'
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
GROUP BY good.article;


select * from goods_categories
where client_id = 625;


/*
Декорадо - 780
*/

SELECT * from goods_categories
where goods_categories.client_id = 4;

SELECT * from goods
where goods.client_id = 780;

select * from clients
where id = 4;


/*
Необходимо выгрузить в таблицу excel клиентов, которые зарегистрировались с 7.10 -29.12:

1) Регион (название группы магазинов)
2) Магазин
3)ФИО
4)Номер телефона
5) Дата регистрации.

Регион можно посмотреть в структуре личного кабинета ( Отчеты-->Продажи-->Структура). Пример выгрузки во вложении
*/

SELECT
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
GROUP BY cards.id;


select sale_general_report from reports_configurations
where client_id = 888;


select * from cards
  INNER JOIN profiles ON profiles.id = cards.profile_id



/*
Загрузить в список
*/

select profiles.id from cards
  INNER JOIN profiles ON profiles.id = cards.profile_id
where cards.client_id = 625
AND cards.uid in ();


/*
Яндекс 0 баланс - 1926
*/
select * from buyer_lists
where buyer_lists.name = 'Яндекс 0 баланс';


select * from cards
where cards.uid = '221188221188';

select * from balance_movements
where card_id = 4778424;

select
  *
from goods_categories
where client_id = 780;

SELECT * from bills
where id = 3742;

update bills
set bills.exported = 1
where id = 3752;


/*
Необходимо по этим спискам клиентов: ГРУППА Кофейники 496979 и ГРУППА ХОТдог за 88 проверить покупали ли клиенты следующий товары за определенный период:( списки можно совместить)

52 неделя  - 28.12 - 03.01
53 неделя - 04.01-10.01


Файл с артикулами во вложении
*/

/*
ГРУППА Кофейники 496979 - 1920
ГРУППА ХОТдог за 88 - 1918
*/
SELECT * from buyer_lists
WHERE client_id = 625
and name = 'ГРУППА ХОТдог за 88';

SELECT buyers from buyers_list
where buyers_list.buyer_list_id = 1920;

select id from cards
where cards.profile_id in ()

SELECT
  good.article,
  count(good.id)
FROM cards
  INNER JOIN (
               SELECT
                 orders.*,
                 goods.article
               FROM orders
                 INNER JOIN goods_incomes ON orders.id = goods_incomes.order_id
                 INNER JOIN goods ON goods.id = goods_incomes.goods_id
               WHERE orders.client_id = 625
                     AND orders.from >= '2021-01-04'
                     AND orders.from <= '2021-01-10 23:59:59'
                     AND goods.article IN (
                 '017811',
                 '017812',
                 '017813',
                 '008548',
                 '003223',
                 '017817',
                 '024528',
                 '025531',
                 '022783',
                 '020403',
                 '013919',
                 '013918'
               )
             ) AS good ON good.card_id = cards.id
WHERE cards.client_id = 625
  AND cards.id in ()
GROUP BY good.article;



select *
from goods_categories
where client_id = 780;

SELECT * from goods_categories
where client_id = 780
      and name = 'ДВП';


SELECT * from goods_categories
where client_id = 780
      and uid = 'e5d4a65b-94eb-11e1-94b5-2c27d73a4ac6';

SELECT * from goods_categories
where client_id = 780
      and id = 771819;

/*
Необходимо выгрузить 2 таблицы Excel по базе клиентов:

1) 1000 номеров, совершивших наибольшее количество покупок с самого начала по 31.12.20 ( ФИО, Номер карты, Кол-во покупок, Номер телефона, Согласие на смс ( да/нет))

2)1000 номеров, совершивших покупку на наибольшую сумму с самого начала по 31.12.20 ( ФИО,Номер карты, Общая сумма покупок,Согласие на смс ( да/нет))
*/

select
  profiles.name,
  cards.uid,
  count(orders.id) as count_orders,
  profiles.phone,
  profiles.send_sms
from cards
inner join profiles on profiles.card_id = cards.id
inner join orders on orders.card_id = cards.id
where cards.client_id = 211
  and orders.from <= '2020-12-31 23:59:59'
GROUP BY cards.id
ORDER BY count_orders DESC
LIMIT 1000;


select
  profiles.name,
  cards.uid,
  ROUND(sum(orders.summary), 2) as sum_orders,
  profiles.send_sms
from cards
  inner join profiles on profiles.card_id = cards.id
  inner join orders on orders.card_id = cards.id
where cards.client_id = 211
      and orders.from <= '2020-12-31 23:59:59'
GROUP BY cards.id
ORDER BY sum_orders DESC
LIMIT 1000;


SELECT id
FROM balance_movements
WHERE client_id = 773
      AND balance_movements.from_date >= '2021-02-19 16:00:00'
      AND balance_movements.from_date <= '2021-02-19 23:59:59';

UPDATE balance_movements
SET balance_movements.end_date = NOW()
WHERE balance_movements.card_id IN
      ('1210987', '1857156', '1448546', '1210420', '1210520', '1210335', '1210336', '1210521', '1211242', '1211310', '1211343', '1211591', '1249076', '1288518', '1288743', '1288946', '1289970', '1290071', '1290167', '1292008', '1294634', '1318285', '1328339', '1438334', '1438374', '1443671', '1446860', '1456864', '1456906', '1457183', '1457583', '1472897', '1473511', '1484105', '1488741', '1686115', '1686926', '1687569', '1799724', '1803753', '1809941', '2862196', '2862372', '2907646', '2918326', '2943097', '3716589', '3716734', '3758192', '3990206', '3990208', '4358331', '4576722', '4611011', '4633644', '4745357', '4835292', '4887212', '4887215', '4890201', '4891017', '4906522', '4918050', '4921234', '4926626', '4933332', '4948028', '4950620')
      AND client_id = 773
      AND balance_movements.from_date >= '2021-02-19 16:00:00'
      AND balance_movements.from_date <= '2021-02-19 23:59:59'
      AND balance_movements.is_positive = 1;

UPDATE cards
SET cards.next_recalc = NOW()
where cards.id in ('1210987', '1857156', '1448546', '1210420', '1210520', '1210335', '1210336', '1210521', '1211242', '1211310', '1211343', '1211591', '1249076', '1288518', '1288743', '1288946', '1289970', '1290071', '1290167', '1292008', '1294634', '1318285', '1328339', '1438334', '1438374', '1443671', '1446860', '1456864', '1456906', '1457183', '1457583', '1472897', '1473511', '1484105', '1488741', '1686115', '1686926', '1687569', '1799724', '1803753', '1809941', '2862196', '2862372', '2907646', '2918326', '2943097', '3716589', '3716734', '3758192', '3990206', '3990208', '4358331', '4576722', '4611011', '4633644', '4745357', '4835292', '4887212', '4887215', '4890201', '4891017', '4906522', '4918050', '4921234', '4926626', '4933332', '4948028', '4950620');

DELETE from balance_movements
where client_id = 773
and balance_movements.id in ('12180243','12180244','12180245','12180246','12180247','12180248','12180249','12180250','12180251','12180252','12180253','12180254','12180256','12180257','12180258','12180259','12180260','12180261','12180262','12180263','12180264','12180265','12180266','12180267','12180268','12180269','12180270','12180271','12180272','12180273','12180274','12180275','12180276','12180277','12180278','12180279','12180280','12180281','12180282','12180283','12180285','12180286','12180287','12180288','12180290','12180291','12180292','12180293','12180294','12180295','12180296','12180297','12180298','12180299','12180300','12180301','12180302','12180303','12180304','12180305','12180306','12180307','12180308','12180309','12180310','12180311','12180312','12180313');

DELETE from orders
where orders.client_id = 773
and orders.card_id in ('1210987', '1857156', '1448546', '1210420', '1210520', '1210335', '1210336', '1210521', '1211242', '1211310', '1211343', '1211591', '1249076', '1288518', '1288743', '1288946', '1289970', '1290071', '1290167', '1292008', '1294634', '1318285', '1328339', '1438334', '1438374', '1443671', '1446860', '1456864', '1456906', '1457183', '1457583', '1472897', '1473511', '1484105', '1488741', '1686115', '1686926', '1687569', '1799724', '1803753', '1809941', '2862196', '2862372', '2907646', '2918326', '2943097', '3716589', '3716734', '3758192', '3990206', '3990208', '4358331', '4576722', '4611011', '4633644', '4745357', '4835292', '4887212', '4887215', '4890201', '4891017', '4906522', '4918050', '4921234', '4926626', '4933332', '4948028', '4950620')
      AND orders.`from` >= '2021-02-19 16:00:00'
      AND orders.`from` <= '2021-02-19 23:59:59'


/*16 55*/


/*Необходимо  выгрузить данные по клиентам из группы Monopoly и Monopoly2 ( их нужно объединить) .

Таблица во вложении
Monopoly - 1616
Monopoly2 - 1669
*/

SELECT *
FROM buyer_lists
WHERE buyer_lists.client_id = 625;

SELECT buyers
FROM buyers_list
WHERE buyer_list_id = 1669;

SELECT
  COUNT(DISTINCT cards.id),
  COUNT(orders.id),
  ROUND(SUM(orders.summary), 2),
  ROUND(AVG(orders.summary), 2),
  ROUND(SUM(orders.discount), 2),
  ROUND(AVG(orders.discount), 2)
FROM cards
  INNER JOIN orders ON orders.card_id = cards.id
WHERE orders.client_id = 625
      AND orders.`from` >= '2021-02-15'
      AND orders.`from` <= '2021-02-21 23:59:59'
      AND cards.profile_id in ('1106537', '2102691', '2103168', '2142544', '2142550', '2142559', '2142572', '2142579', '2142581', '2142585', '2142592', '2142604', '2142607', '2142618', '2142625', '2142635', '2142640', '2142648', '2142653', '2142657', '2142660', '2142668', '2142675', '2142682', '2142684', '2178182', '2178183', '2178184', '2178185', '2178186', '2178555', '2178557', '2178558', '2178560', '2178561', '2178563', '2178564', '2178565', '2178566', '2178567', '2178568', '2178571', '2178572', '2178573', '2178574', '2178575', '2178576', '2178577', '2178578', '2178579', '2178580', '2178581', '2178582', '2178583', '2178584', '2178585', '2178586', '2178587', '2178588', '2178589', '2178590', '2178591', '2178592', '2178593', '2178594', '2178595', '2178596', '2178597', '2178598', '2178599', '2181747', '2181890', '2181896', '2181898', '2181899', '2181901', '2181903', '2181905', '2181906', '2181907', '2181908', '2182765', '2183654', '2183656', '2183658', '2183660', '2183661', '2183662', '2183663', '2183664', '2183665', '2183666', '2183667', '2183668', '2183669', '2183671', '2183672', '2183673', '2183674', '2183675', '2183676', '2183677', '2186913', '2187560', '2188345', '2188473', '2188478', '2188480', '2188481', '2188483', '2188484', '2188485', '2188488', '2188489', '2188490', '2188491', '2188493', '2188495', '2188496', '2188497', '2188499', '2188500', '2188501', '2188502', '2188503', '2188504', '2188507', '2188509', '2199020', '2199022', '2199025', '2199026', '2199028', '2199032', '2199034', '2199035', '2199038', '2199039', '2201431', '2201432', '2201433', '2201437', '2201438', '2201439', '2201440', '2201441', '2201442', '2204557', '2205103', '2205104', '2205105', '2205106', '2205107', '2205108', '2205109', '2205110', '2205111', '2205112', '2205113', '2205114', '2205115', '2205116', '2205117', '2205118', '2205119', '2205120', '2205121', '2205122', '2205123', '2205124', '2205125', '2205126', '2238806', '2238807', '2238809', '2238810', '2238811', '2238812', '2238813', '2238814', '2238815', '2238816', '2238817', '2238818', '2238819', '2238820', '2238821', '2238827', '2242744', '2242852', '2242855', '2242859', '2242862', '2242866', '2242869', '2242871', '2242872', '2242876', '2242879', '2242881', '2242884', '2242885', '2242887', '2242891', '2242893', '2242894', '2242896', '2242906', '2242996', '2242997', '2242999', '2243005', '2243457', '2243458', '2243502', '2243507', '2243511', '2243513', '2243517', '2243519', '2243521', '2243524', '2243633', '2243635', '2243638', '2243639', '2243642', '2243643', '2243645', '2243648', '2243650', '2276971', '2276972', '2276973', '2276974', '2276975', '2276976', '2276977', '2276978', '2276979', '2276981', '2505635', '2505636', '2505637', '2505638', '2505640', '2505690', '2505691', '2505694', '2505695', '2505710', '2505734', '2505737', '2505739', '2505741', '2505742', '2505744', '2505747', '2505750', '2505753', '2505758', '2505759', '2505760', '2505764', '2505766', '2505769', '2505792', '2505798', '2505799', '2505813', '2505816', '2505820', '2505822', '2505823', '2505826', '2505828', '2505832', '2505834', '2505835', '2505836', '2505839', '2505841', '2505843', '2505844', '2505846', '2505848', '2505850', '2505853', '2505855', '2505859', '2505864', '2505867', '2505868', '2505869', '2505873', '2505877', '2505881', '2505883', '2505884', '2505887', '2505888', '2505890', '2505892', '2505894', '2505895', '2505896', '2505900', '2505902', '2505903', '2505905', '2505906', '2505912', '2505914', '2505917', '2505919', '2505921', '2505924', '2505926', '2505927', '2561825', '2561831', '2561848', '2561871', '2561882', '2561896', '2561924', '2561945', '2561959', '2561969', '2562000', '2742889', '2742892', '2742916', '2742921', '2742926', '2742927', '2742930', '2742935', '2742937', '2743145', '2743147', '2743149', '2743152', '2743153', '2743156', '2743157', '2743159', '2773951', '2773954', '2773958', '2773961', '2773963', '2773966', '2774034', '2778298', '2778302', '2778304', '2778305', '2778307', '2778309', '2778310', '2778313', '2778315', '2778316', '2779033', '2779041', '2779043', '2779044', '2779045', '2779048', '2779050', '2779053', '2779054', '2779055', '2801156', '2806588', '2806591', '2806596', '2806607', '2806616', '2806627', '2806632', '2806635', '2806637', '2825617', '2825622', '2825626', '2825628', '2825631', '2825633', '2825639', '2825641', '2871591', '2871639', '2871642', '2871644', '2871662', '2871697', '2871700', '2872898', '2872900', '2872901', '2872904', '2872906', '2872909', '2872911', '2872912', '2872914', '2872916', '2872920', '2872923', '2872928', '2872932', '2872934', '2872936', '2872937', '2872938', '2872939', '2872941', '2872944', '2872948', '2872950', '2872951', '2872953', '2872959', '2872961', '2872967', '2872969', '2872971', '2872974', '2872979', '2872982', '2872983', '2872987', '2872988', '2872989', '2872993', '2872996', '2872998', '2873000', '2873002', '2873003', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3104511', '2223056', '2223081', '2223084', '2223088', '2223094', '2223100', '2224626', '2224627', '2224628', '2224629', '2224630', '2224631', '2224632', '2224633', '2224634', '2224635', '2224636', '2224637', '2224638', '2224639', '2224640', '2224652', '2224653', '2224654', '2224655', '2224656', '2224657', '2224658', '2224659', '2224660', '2224661', '2224662', '2224663', '2224664', '2224665', '2224666', '2224667', '2224668', '2224669', '2224670', '2224671', '2224672', '2224673', '2224674', '2224675', '2224676', '2224677', '2224678', '2224679', '2224680', '2224681', '2224682', '2224683', '2224684', '2224685', '2224686', '2224687', '2224688', '2224689', '2224690', '2224691', '2224692', '2224693', '2224694', '2224695', '2224696', '2224697', '2224698', '2224699', '2224700', '2224701', '2224702', '2224703', '2224704', '2224705', '2224706', '2224707', '2224708', '2224709', '2224710', '2224711', '2224712', '2224713', '2224714', '2224715', '2224716', '2224717', '2224718', '2224719', '2224720', '2224721', '2224722', '2224723', '2224724', '2224725', '2224726', '2224727', '2224728', '2224729', '2224730', '2224731', '2224732', '2224733', '2224734', '2224735', '2224736', '2224737', '2224738', '2224739', '2224740', '2224741', '2224742', '2224743', '2224744', '2224745', '2224746', '2224747', '2224748', '2224749', '2224750', '2224751', '2224752', '2224753', '2224754', '2224755', '2224756', '2224757', '2224758', '2224759', '2224760', '2224761', '2224762', '2224763', '2224764', '2224765', '2224766', '2224767', '2224768', '2224769', '2224770', '2224771', '2224772', '2224773', '2224774', '2224775', '2224776', '2224777', '2224778', '2224779', '2224780', '2224781', '2224782', '2224783', '2224784', '2224785', '2224786', '2224787', '2224788', '2224789', '2224790', '2224791', '2224792', '2224793', '2224794', '2224795', '2224796', '2224797', '2224798', '2224799', '2224800', '2224801', '2224802', '2224803', '2224804', '2224805', '2224806', '2224807', '2224808', '2224809', '2224810', '2224811', '2224812', '2224813', '2224814', '2224815', '2224816', '2224817', '2224818', '2224819', '2224820', '2224821', '2224822', '2224823', '2224824', '2224825', '2224826', '2224827', '2224828', '2224829', '2224830', '2224831', '2224832', '2224833', '2224834', '2224835', '2224836', '2224837', '2224838', '2224839', '2224840', '2224841', '2224842', '2224843', '2224844', '2224845', '2224846', '2224847', '2224848', '2224849', '2224850', '2224851', '2224852', '2224853', '2224854', '2224855', '2224856', '2224857', '2224858', '2224859', '2224860', '2224861', '2224862', '2224863', '2224864', '2224865', '2224866', '2224867', '2224868', '2224869', '2224870', '2224871', '2224872', '2224873', '2224874', '2224875', '2224876', '2224877', '2224878', '2224879', '2224880', '2224881', '2224882', '2224883', '2224884', '2224885', '2224886', '2224887', '2224888', '2224889', '2224890', '2224891', '2224892', '2224893', '2224894', '2224895', '2224896', '2224897', '2224898', '2224899', '2224900', '2224901', '2224902', '2224903', '2224904', '2224905', '2224906', '2224907', '2224908', '2224909', '2224910', '2224911', '2224912', '2224913', '2224914', '2224915', '2224916', '2224917', '2224918', '2224919', '2224920', '2224921', '2224922', '2224923', '2224924', '2224925', '2224926', '2224927', '2224928', '2224929', '2224930', '2224931', '2224932', '2224933', '2224934', '2224935', '2224936', '2224937', '2224938', '2224939', '2224940', '2224941', '2224942', '2224943', '2224944', '2224945', '2224946', '2224947', '2224948', '2224949', '2224950', '2224951', '2224952', '2224953', '2224954', '2224955', '2224956', '2224957', '2224958', '2224959', '2224960', '2224961', '2224962', '2224963', '2224964', '2224965', '2224966', '2224967', '2224968', '2224969', '2224970', '2224971', '2224972', '2224973', '2224974', '2224975', '2224976', '2224977', '2224978', '2224979', '2224980', '2224981', '2224982', '2224983', '2224984', '2224985', '2224986', '2224987', '2224988', '2224989', '2224990', '2224991', '2224992', '2224993', '2224994', '2224995', '2224996', '2224997', '2224998', '2224999', '2225000', '2225001', '2225002', '2225003', '2225004', '2225005', '2225006', '2225007', '2225008', '2225009', '2225010', '2225011', '2225012', '2225014', '2225015', '2225016', '2225017', '2225018', '2225019', '2225020', '2225021', '2225022', '2225023', '2225024', '2225025', '2225026', '2225027', '2225028', '2225029', '2225030', '2225031', '2225032', '2225033', '2225034', '2225035', '2225036', '2225037', '2225038', '2225039', '2225040', '2225041', '2225042', '2225043', '2225044', '2225045', '2225046', '2225047', '2225048', '2225049', '2225050', '2225051', '2225052', '2225053', '2225054', '2225055', '2225056', '2225057', '2225058', '2225059', '2225060', '2225061', '2225062', '2225063', '2225064', '2225065', '2225066', '2225067', '2225068', '2225069', '2225070', '2225071', '2225072', '2225073', '2225074', '2225075', '2225076', '2225077', '2225078', '2225079', '2225080', '2225081', '2225082', '2225083', '2225084', '2225085', '2225086', '2225087', '2225088', '2225089', '2225090', '2225091', '2225092', '2225093', '2225094', '2225095', '2225096', '2225097', '2225098', '2225099', '2225100', '2225101', '2225102', '2225103', '2225104', '2225105', '2225106', '2225107', '2225108', '2225109', '2225110', '2225111', '2225112', '2225113', '2225114', '2225115', '2225116', '2225117', '2225118', '2225119', '2225120', '2225121', '2225122', '2225123', '2225124', '2225125', '2225126', '2225127', '2225128', '2225129', '2225130', '2244128', '2244129', '2244130', '2244131', '2244132', '2244133', '2244134', '2244135', '2244136', '2244137', '2244138', '2244139', '2244140', '2244141', '2244142', '2244143', '2244144', '2244145', '2244146', '2244147', '2244148', '2244149', '2244150', '2244151', '2244152', '2244153', '2244154', '2244155', '2244156', '2244157', '2244158', '2244159', '2244160', '2244161', '2244162', '2244163', '2244164', '2244165', '2244166', '2244167', '2244168', '2244169', '2244170', '2244171', '2244172', '2244173', '2244174', '2244175', '2244176', '2244177', '2244178', '2244179', '2244180', '2244181', '2244182', '2244183', '2244184', '2244185', '2244186', '2244187', '2244188', '2244189', '2244190', '2244191', '2244192', '2244193', '2244194', '2244195', '2244196', '2244197', '2244198', '2244199', '2244200', '2244201', '2244202', '2244203', '2244204', '2244205', '2244206', '2244207', '2244208', '2244209', '2244210', '2244211', '2244212', '2244213', '2244214', '2244215', '2244216', '2244217', '2244218', '2244219', '2244220', '2244221', '2244222', '2244223', '2244224', '2244225', '2244226', '2244227', '2244228', '2244229', '2244230', '2244232', '2244233', '2244234', '2244235', '2244236', '2244237', '2244238', '2244239', '2244240', '2244241', '2244242', '2244243', '2244244', '2244245', '2244246', '2244247', '2244248', '2244249', '2244250', '2244251', '2244252', '2244253', '2244254', '2244255', '2244256', '2244257', '2244258', '2244259', '2244260', '2244261', '2244262', '2244263', '2244264', '2244265', '2244266', '2244267', '2244268', '2244269', '2244270', '2244271', '2244272', '2244273', '2244274', '2244275', '2244276', '2244277', '2244278', '2244279', '2244280', '2244281', '2244282', '2244283', '2244284', '2244285', '2244286', '2244287', '2244288', '2244289', '2244290', '2244291', '2244292', '2244293', '2244294', '2244295', '2244296', '2244297', '2244298', '2244299', '2244300', '2244301', '2244302', '2244303', '2244304', '2244305', '2244306', '2244307', '2244308', '2244309', '2244310', '2244311', '2244312', '2244313', '2244314', '2244315', '2244316', '2244317', '2244318', '2244319', '2244320', '2244321', '2244322', '2244323', '2244324', '2244325', '2244326', '2244327', '2244328', '2244329', '2244330', '2244331', '2244332', '2244333', '2244334', '2244335', '2244336', '2244337', '2244338', '2244339', '2244340', '2244341', '2244342', '2244343', '2244344', '2244345', '2244346', '2244347', '2244348', '2244349', '2244350', '2244351', '2244352', '2244353', '2244354', '2244355', '2244356', '2244357', '2244358', '2244359', '2244360', '2244361', '2244362', '2244363', '2244364', '2244365', '2244366', '2244367', '2244368', '2244369', '2244370', '2244371', '2244372', '2244373', '2244374', '2244375', '2244376', '2244377', '2244378', '2244379', '2244380', '2244381', '2244382', '2244383', '2244384', '2244385', '2244386', '2244387', '2244388', '2244389', '2244390', '2244391', '2244392', '2244393', '2244394', '2244395', '2244396', '2244397', '2244398', '2244399', '2244400', '2244401', '2244402', '2244403', '2244404', '2244405', '2244406', '2244407', '2244408', '2244409', '2244410', '2244411', '2244412', '2244413', '2244414', '2244415', '2244416', '2244417', '2244418', '2244419', '2244420', '2244421', '2244422', '2244423', '2244424', '2244425', '2244426', '2244427', '2244428', '2244429', '2244430', '2244431', '2244432', '2244433', '2244434', '2244435', '2244436', '2244437', '2244438', '2244439', '2244440', '2244441', '2244442', '2244443', '2244444', '2244445', '2244446', '2244447', '2244448', '2244449', '2244450', '2244451', '2244452', '2244453', '2244454', '2244455', '2244456', '2244457', '2244458', '2244459', '2244460', '2244461', '2244462', '2244463', '2244464', '2244465', '2416408', '2416410', '2416413', '2416419', '2416420', '2416422', '2416423', '2416427', '2416429', '2416431', '2416437', '2416439', '2416445', '2416447', '2416448', '2416450', '2416451', '2416452', '2416492', '2604355', '2806580', '2806601', '2806609', '2806620', '2806649', '3029012', '3029014', '3029015', '3029018', '3029020', '3029022', '3029023', '3029024', '3029025', '3029027', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3038792', '3038797', '3038799', '3038802', '3038810', '3038813', '3038815', '3038820', '3038823', '3038824', '3038833', '3038834', '3038836', '3038837', '3038838', '3038839', '3038841', '3038842', '3038843', '3038844', '3038845', '3038846', '3038849', '3038851', '3038860', '3038861', '3038862', '3038863', '3038864', '3038865', '3065554', '3065556', '3065559', '3065563', '3065567', '3065571', '3065586', '3065588', '3065594', '3065598', '3065601', '3065606', '3065613', '3065627', '3065628', '3065631', '3065635', '3065638', '3065639', '3065642', '3104826', '3104831', '3104832', '3104833', '3104834', '3104835', '3104836', '3104838', '3104840', '3104841', '3104844', '3104845', '3104847', '3104849', '3104850', '3104852', '3104854', '3104857', '3104861', '3104862', '3104865', '3104868', '3104871', '3104873', '3104876', '3104877', '3104879', '3104880', '3104881', '3104888', '3104950', '3104953', '3104954', '3104955', '3104956', '3104958', '3104961', '3104963', '3104965', '3104970', '3104971', '3104972', '3104973', '3104975', '3104981', '3104982', '3104984', '3104993', '3104999')


/* Записали номер телефон*/
SELECT
  hpc.amount
FROM cards
  INNER JOIN profiles ON profiles.id = cards.profile_id AND cards.id = profiles.card_id
  INNER JOIN (
               SELECT count(history_profiles_change.id) as amount, profile_id
               FROM history_profiles_change
               WHERE client_id = 625
                     AND history_profiles_change.is_creation = false
                     AND history_profiles_change.created_at >= '2021-02-08'
                     AND history_profiles_change.created_at <= '2021-02-14'
                     AND history_profiles_change.profile_id in ('1106537', '2102691', '2103168', '2142544', '2142550', '2142559', '2142572', '2142579', '2142581', '2142585', '2142592', '2142604', '2142607', '2142618', '2142625', '2142635', '2142640', '2142648', '2142653', '2142657', '2142660', '2142668', '2142675', '2142682', '2142684', '2178182', '2178183', '2178184', '2178185', '2178186', '2178555', '2178557', '2178558', '2178560', '2178561', '2178563', '2178564', '2178565', '2178566', '2178567', '2178568', '2178571', '2178572', '2178573', '2178574', '2178575', '2178576', '2178577', '2178578', '2178579', '2178580', '2178581', '2178582', '2178583', '2178584', '2178585', '2178586', '2178587', '2178588', '2178589', '2178590', '2178591', '2178592', '2178593', '2178594', '2178595', '2178596', '2178597', '2178598', '2178599', '2181747', '2181890', '2181896', '2181898', '2181899', '2181901', '2181903', '2181905', '2181906', '2181907', '2181908', '2182765', '2183654', '2183656', '2183658', '2183660', '2183661', '2183662', '2183663', '2183664', '2183665', '2183666', '2183667', '2183668', '2183669', '2183671', '2183672', '2183673', '2183674', '2183675', '2183676', '2183677', '2186913', '2187560', '2188345', '2188473', '2188478', '2188480', '2188481', '2188483', '2188484', '2188485', '2188488', '2188489', '2188490', '2188491', '2188493', '2188495', '2188496', '2188497', '2188499', '2188500', '2188501', '2188502', '2188503', '2188504', '2188507', '2188509', '2199020', '2199022', '2199025', '2199026', '2199028', '2199032', '2199034', '2199035', '2199038', '2199039', '2201431', '2201432', '2201433', '2201437', '2201438', '2201439', '2201440', '2201441', '2201442', '2204557', '2205103', '2205104', '2205105', '2205106', '2205107', '2205108', '2205109', '2205110', '2205111', '2205112', '2205113', '2205114', '2205115', '2205116', '2205117', '2205118', '2205119', '2205120', '2205121', '2205122', '2205123', '2205124', '2205125', '2205126', '2238806', '2238807', '2238809', '2238810', '2238811', '2238812', '2238813', '2238814', '2238815', '2238816', '2238817', '2238818', '2238819', '2238820', '2238821', '2238827', '2242744', '2242852', '2242855', '2242859', '2242862', '2242866', '2242869', '2242871', '2242872', '2242876', '2242879', '2242881', '2242884', '2242885', '2242887', '2242891', '2242893', '2242894', '2242896', '2242906', '2242996', '2242997', '2242999', '2243005', '2243457', '2243458', '2243502', '2243507', '2243511', '2243513', '2243517', '2243519', '2243521', '2243524', '2243633', '2243635', '2243638', '2243639', '2243642', '2243643', '2243645', '2243648', '2243650', '2276971', '2276972', '2276973', '2276974', '2276975', '2276976', '2276977', '2276978', '2276979', '2276981', '2505635', '2505636', '2505637', '2505638', '2505640', '2505690', '2505691', '2505694', '2505695', '2505710', '2505734', '2505737', '2505739', '2505741', '2505742', '2505744', '2505747', '2505750', '2505753', '2505758', '2505759', '2505760', '2505764', '2505766', '2505769', '2505792', '2505798', '2505799', '2505813', '2505816', '2505820', '2505822', '2505823', '2505826', '2505828', '2505832', '2505834', '2505835', '2505836', '2505839', '2505841', '2505843', '2505844', '2505846', '2505848', '2505850', '2505853', '2505855', '2505859', '2505864', '2505867', '2505868', '2505869', '2505873', '2505877', '2505881', '2505883', '2505884', '2505887', '2505888', '2505890', '2505892', '2505894', '2505895', '2505896', '2505900', '2505902', '2505903', '2505905', '2505906', '2505912', '2505914', '2505917', '2505919', '2505921', '2505924', '2505926', '2505927', '2561825', '2561831', '2561848', '2561871', '2561882', '2561896', '2561924', '2561945', '2561959', '2561969', '2562000', '2742889', '2742892', '2742916', '2742921', '2742926', '2742927', '2742930', '2742935', '2742937', '2743145', '2743147', '2743149', '2743152', '2743153', '2743156', '2743157', '2743159', '2773951', '2773954', '2773958', '2773961', '2773963', '2773966', '2774034', '2778298', '2778302', '2778304', '2778305', '2778307', '2778309', '2778310', '2778313', '2778315', '2778316', '2779033', '2779041', '2779043', '2779044', '2779045', '2779048', '2779050', '2779053', '2779054', '2779055', '2801156', '2806588', '2806591', '2806596', '2806607', '2806616', '2806627', '2806632', '2806635', '2806637', '2825617', '2825622', '2825626', '2825628', '2825631', '2825633', '2825639', '2825641', '2871591', '2871639', '2871642', '2871644', '2871662', '2871697', '2871700', '2872898', '2872900', '2872901', '2872904', '2872906', '2872909', '2872911', '2872912', '2872914', '2872916', '2872920', '2872923', '2872928', '2872932', '2872934', '2872936', '2872937', '2872938', '2872939', '2872941', '2872944', '2872948', '2872950', '2872951', '2872953', '2872959', '2872961', '2872967', '2872969', '2872971', '2872974', '2872979', '2872982', '2872983', '2872987', '2872988', '2872989', '2872993', '2872996', '2872998', '2873000', '2873002', '2873003', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3104511', '2223056', '2223081', '2223084', '2223088', '2223094', '2223100', '2224626', '2224627', '2224628', '2224629', '2224630', '2224631', '2224632', '2224633', '2224634', '2224635', '2224636', '2224637', '2224638', '2224639', '2224640', '2224652', '2224653', '2224654', '2224655', '2224656', '2224657', '2224658', '2224659', '2224660', '2224661', '2224662', '2224663', '2224664', '2224665', '2224666', '2224667', '2224668', '2224669', '2224670', '2224671', '2224672', '2224673', '2224674', '2224675', '2224676', '2224677', '2224678', '2224679', '2224680', '2224681', '2224682', '2224683', '2224684', '2224685', '2224686', '2224687', '2224688', '2224689', '2224690', '2224691', '2224692', '2224693', '2224694', '2224695', '2224696', '2224697', '2224698', '2224699', '2224700', '2224701', '2224702', '2224703', '2224704', '2224705', '2224706', '2224707', '2224708', '2224709', '2224710', '2224711', '2224712', '2224713', '2224714', '2224715', '2224716', '2224717', '2224718', '2224719', '2224720', '2224721', '2224722', '2224723', '2224724', '2224725', '2224726', '2224727', '2224728', '2224729', '2224730', '2224731', '2224732', '2224733', '2224734', '2224735', '2224736', '2224737', '2224738', '2224739', '2224740', '2224741', '2224742', '2224743', '2224744', '2224745', '2224746', '2224747', '2224748', '2224749', '2224750', '2224751', '2224752', '2224753', '2224754', '2224755', '2224756', '2224757', '2224758', '2224759', '2224760', '2224761', '2224762', '2224763', '2224764', '2224765', '2224766', '2224767', '2224768', '2224769', '2224770', '2224771', '2224772', '2224773', '2224774', '2224775', '2224776', '2224777', '2224778', '2224779', '2224780', '2224781', '2224782', '2224783', '2224784', '2224785', '2224786', '2224787', '2224788', '2224789', '2224790', '2224791', '2224792', '2224793', '2224794', '2224795', '2224796', '2224797', '2224798', '2224799', '2224800', '2224801', '2224802', '2224803', '2224804', '2224805', '2224806', '2224807', '2224808', '2224809', '2224810', '2224811', '2224812', '2224813', '2224814', '2224815', '2224816', '2224817', '2224818', '2224819', '2224820', '2224821', '2224822', '2224823', '2224824', '2224825', '2224826', '2224827', '2224828', '2224829', '2224830', '2224831', '2224832', '2224833', '2224834', '2224835', '2224836', '2224837', '2224838', '2224839', '2224840', '2224841', '2224842', '2224843', '2224844', '2224845', '2224846', '2224847', '2224848', '2224849', '2224850', '2224851', '2224852', '2224853', '2224854', '2224855', '2224856', '2224857', '2224858', '2224859', '2224860', '2224861', '2224862', '2224863', '2224864', '2224865', '2224866', '2224867', '2224868', '2224869', '2224870', '2224871', '2224872', '2224873', '2224874', '2224875', '2224876', '2224877', '2224878', '2224879', '2224880', '2224881', '2224882', '2224883', '2224884', '2224885', '2224886', '2224887', '2224888', '2224889', '2224890', '2224891', '2224892', '2224893', '2224894', '2224895', '2224896', '2224897', '2224898', '2224899', '2224900', '2224901', '2224902', '2224903', '2224904', '2224905', '2224906', '2224907', '2224908', '2224909', '2224910', '2224911', '2224912', '2224913', '2224914', '2224915', '2224916', '2224917', '2224918', '2224919', '2224920', '2224921', '2224922', '2224923', '2224924', '2224925', '2224926', '2224927', '2224928', '2224929', '2224930', '2224931', '2224932', '2224933', '2224934', '2224935', '2224936', '2224937', '2224938', '2224939', '2224940', '2224941', '2224942', '2224943', '2224944', '2224945', '2224946', '2224947', '2224948', '2224949', '2224950', '2224951', '2224952', '2224953', '2224954', '2224955', '2224956', '2224957', '2224958', '2224959', '2224960', '2224961', '2224962', '2224963', '2224964', '2224965', '2224966', '2224967', '2224968', '2224969', '2224970', '2224971', '2224972', '2224973', '2224974', '2224975', '2224976', '2224977', '2224978', '2224979', '2224980', '2224981', '2224982', '2224983', '2224984', '2224985', '2224986', '2224987', '2224988', '2224989', '2224990', '2224991', '2224992', '2224993', '2224994', '2224995', '2224996', '2224997', '2224998', '2224999', '2225000', '2225001', '2225002', '2225003', '2225004', '2225005', '2225006', '2225007', '2225008', '2225009', '2225010', '2225011', '2225012', '2225014', '2225015', '2225016', '2225017', '2225018', '2225019', '2225020', '2225021', '2225022', '2225023', '2225024', '2225025', '2225026', '2225027', '2225028', '2225029', '2225030', '2225031', '2225032', '2225033', '2225034', '2225035', '2225036', '2225037', '2225038', '2225039', '2225040', '2225041', '2225042', '2225043', '2225044', '2225045', '2225046', '2225047', '2225048', '2225049', '2225050', '2225051', '2225052', '2225053', '2225054', '2225055', '2225056', '2225057', '2225058', '2225059', '2225060', '2225061', '2225062', '2225063', '2225064', '2225065', '2225066', '2225067', '2225068', '2225069', '2225070', '2225071', '2225072', '2225073', '2225074', '2225075', '2225076', '2225077', '2225078', '2225079', '2225080', '2225081', '2225082', '2225083', '2225084', '2225085', '2225086', '2225087', '2225088', '2225089', '2225090', '2225091', '2225092', '2225093', '2225094', '2225095', '2225096', '2225097', '2225098', '2225099', '2225100', '2225101', '2225102', '2225103', '2225104', '2225105', '2225106', '2225107', '2225108', '2225109', '2225110', '2225111', '2225112', '2225113', '2225114', '2225115', '2225116', '2225117', '2225118', '2225119', '2225120', '2225121', '2225122', '2225123', '2225124', '2225125', '2225126', '2225127', '2225128', '2225129', '2225130', '2244128', '2244129', '2244130', '2244131', '2244132', '2244133', '2244134', '2244135', '2244136', '2244137', '2244138', '2244139', '2244140', '2244141', '2244142', '2244143', '2244144', '2244145', '2244146', '2244147', '2244148', '2244149', '2244150', '2244151', '2244152', '2244153', '2244154', '2244155', '2244156', '2244157', '2244158', '2244159', '2244160', '2244161', '2244162', '2244163', '2244164', '2244165', '2244166', '2244167', '2244168', '2244169', '2244170', '2244171', '2244172', '2244173', '2244174', '2244175', '2244176', '2244177', '2244178', '2244179', '2244180', '2244181', '2244182', '2244183', '2244184', '2244185', '2244186', '2244187', '2244188', '2244189', '2244190', '2244191', '2244192', '2244193', '2244194', '2244195', '2244196', '2244197', '2244198', '2244199', '2244200', '2244201', '2244202', '2244203', '2244204', '2244205', '2244206', '2244207', '2244208', '2244209', '2244210', '2244211', '2244212', '2244213', '2244214', '2244215', '2244216', '2244217', '2244218', '2244219', '2244220', '2244221', '2244222', '2244223', '2244224', '2244225', '2244226', '2244227', '2244228', '2244229', '2244230', '2244232', '2244233', '2244234', '2244235', '2244236', '2244237', '2244238', '2244239', '2244240', '2244241', '2244242', '2244243', '2244244', '2244245', '2244246', '2244247', '2244248', '2244249', '2244250', '2244251', '2244252', '2244253', '2244254', '2244255', '2244256', '2244257', '2244258', '2244259', '2244260', '2244261', '2244262', '2244263', '2244264', '2244265', '2244266', '2244267', '2244268', '2244269', '2244270', '2244271', '2244272', '2244273', '2244274', '2244275', '2244276', '2244277', '2244278', '2244279', '2244280', '2244281', '2244282', '2244283', '2244284', '2244285', '2244286', '2244287', '2244288', '2244289', '2244290', '2244291', '2244292', '2244293', '2244294', '2244295', '2244296', '2244297', '2244298', '2244299', '2244300', '2244301', '2244302', '2244303', '2244304', '2244305', '2244306', '2244307', '2244308', '2244309', '2244310', '2244311', '2244312', '2244313', '2244314', '2244315', '2244316', '2244317', '2244318', '2244319', '2244320', '2244321', '2244322', '2244323', '2244324', '2244325', '2244326', '2244327', '2244328', '2244329', '2244330', '2244331', '2244332', '2244333', '2244334', '2244335', '2244336', '2244337', '2244338', '2244339', '2244340', '2244341', '2244342', '2244343', '2244344', '2244345', '2244346', '2244347', '2244348', '2244349', '2244350', '2244351', '2244352', '2244353', '2244354', '2244355', '2244356', '2244357', '2244358', '2244359', '2244360', '2244361', '2244362', '2244363', '2244364', '2244365', '2244366', '2244367', '2244368', '2244369', '2244370', '2244371', '2244372', '2244373', '2244374', '2244375', '2244376', '2244377', '2244378', '2244379', '2244380', '2244381', '2244382', '2244383', '2244384', '2244385', '2244386', '2244387', '2244388', '2244389', '2244390', '2244391', '2244392', '2244393', '2244394', '2244395', '2244396', '2244397', '2244398', '2244399', '2244400', '2244401', '2244402', '2244403', '2244404', '2244405', '2244406', '2244407', '2244408', '2244409', '2244410', '2244411', '2244412', '2244413', '2244414', '2244415', '2244416', '2244417', '2244418', '2244419', '2244420', '2244421', '2244422', '2244423', '2244424', '2244425', '2244426', '2244427', '2244428', '2244429', '2244430', '2244431', '2244432', '2244433', '2244434', '2244435', '2244436', '2244437', '2244438', '2244439', '2244440', '2244441', '2244442', '2244443', '2244444', '2244445', '2244446', '2244447', '2244448', '2244449', '2244450', '2244451', '2244452', '2244453', '2244454', '2244455', '2244456', '2244457', '2244458', '2244459', '2244460', '2244461', '2244462', '2244463', '2244464', '2244465', '2416408', '2416410', '2416413', '2416419', '2416420', '2416422', '2416423', '2416427', '2416429', '2416431', '2416437', '2416439', '2416445', '2416447', '2416448', '2416450', '2416451', '2416452', '2416492', '2604355', '2806580', '2806601', '2806609', '2806620', '2806649', '3029012', '3029014', '3029015', '3029018', '3029020', '3029022', '3029023', '3029024', '3029025', '3029027', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3038792', '3038797', '3038799', '3038802', '3038810', '3038813', '3038815', '3038820', '3038823', '3038824', '3038833', '3038834', '3038836', '3038837', '3038838', '3038839', '3038841', '3038842', '3038843', '3038844', '3038845', '3038846', '3038849', '3038851', '3038860', '3038861', '3038862', '3038863', '3038864', '3038865', '3065554', '3065556', '3065559', '3065563', '3065567', '3065571', '3065586', '3065588', '3065594', '3065598', '3065601', '3065606', '3065613', '3065627', '3065628', '3065631', '3065635', '3065638', '3065639', '3065642', '3104826', '3104831', '3104832', '3104833', '3104834', '3104835', '3104836', '3104838', '3104840', '3104841', '3104844', '3104845', '3104847', '3104849', '3104850', '3104852', '3104854', '3104857', '3104861', '3104862', '3104865', '3104868', '3104871', '3104873', '3104876', '3104877', '3104879', '3104880', '3104881', '3104888', '3104950', '3104953', '3104954', '3104955', '3104956', '3104958', '3104961', '3104963', '3104965', '3104970', '3104971', '3104972', '3104973', '3104975', '3104981', '3104982', '3104984', '3104993', '3104999')
             ) AS hpc ON hpc.profile_id = profiles.id
WHERE cards.client_id = 625
      AND cards.profile_id in ('1106537', '2102691', '2103168', '2142544', '2142550', '2142559', '2142572', '2142579', '2142581', '2142585', '2142592', '2142604', '2142607', '2142618', '2142625', '2142635', '2142640', '2142648', '2142653', '2142657', '2142660', '2142668', '2142675', '2142682', '2142684', '2178182', '2178183', '2178184', '2178185', '2178186', '2178555', '2178557', '2178558', '2178560', '2178561', '2178563', '2178564', '2178565', '2178566', '2178567', '2178568', '2178571', '2178572', '2178573', '2178574', '2178575', '2178576', '2178577', '2178578', '2178579', '2178580', '2178581', '2178582', '2178583', '2178584', '2178585', '2178586', '2178587', '2178588', '2178589', '2178590', '2178591', '2178592', '2178593', '2178594', '2178595', '2178596', '2178597', '2178598', '2178599', '2181747', '2181890', '2181896', '2181898', '2181899', '2181901', '2181903', '2181905', '2181906', '2181907', '2181908', '2182765', '2183654', '2183656', '2183658', '2183660', '2183661', '2183662', '2183663', '2183664', '2183665', '2183666', '2183667', '2183668', '2183669', '2183671', '2183672', '2183673', '2183674', '2183675', '2183676', '2183677', '2186913', '2187560', '2188345', '2188473', '2188478', '2188480', '2188481', '2188483', '2188484', '2188485', '2188488', '2188489', '2188490', '2188491', '2188493', '2188495', '2188496', '2188497', '2188499', '2188500', '2188501', '2188502', '2188503', '2188504', '2188507', '2188509', '2199020', '2199022', '2199025', '2199026', '2199028', '2199032', '2199034', '2199035', '2199038', '2199039', '2201431', '2201432', '2201433', '2201437', '2201438', '2201439', '2201440', '2201441', '2201442', '2204557', '2205103', '2205104', '2205105', '2205106', '2205107', '2205108', '2205109', '2205110', '2205111', '2205112', '2205113', '2205114', '2205115', '2205116', '2205117', '2205118', '2205119', '2205120', '2205121', '2205122', '2205123', '2205124', '2205125', '2205126', '2238806', '2238807', '2238809', '2238810', '2238811', '2238812', '2238813', '2238814', '2238815', '2238816', '2238817', '2238818', '2238819', '2238820', '2238821', '2238827', '2242744', '2242852', '2242855', '2242859', '2242862', '2242866', '2242869', '2242871', '2242872', '2242876', '2242879', '2242881', '2242884', '2242885', '2242887', '2242891', '2242893', '2242894', '2242896', '2242906', '2242996', '2242997', '2242999', '2243005', '2243457', '2243458', '2243502', '2243507', '2243511', '2243513', '2243517', '2243519', '2243521', '2243524', '2243633', '2243635', '2243638', '2243639', '2243642', '2243643', '2243645', '2243648', '2243650', '2276971', '2276972', '2276973', '2276974', '2276975', '2276976', '2276977', '2276978', '2276979', '2276981', '2505635', '2505636', '2505637', '2505638', '2505640', '2505690', '2505691', '2505694', '2505695', '2505710', '2505734', '2505737', '2505739', '2505741', '2505742', '2505744', '2505747', '2505750', '2505753', '2505758', '2505759', '2505760', '2505764', '2505766', '2505769', '2505792', '2505798', '2505799', '2505813', '2505816', '2505820', '2505822', '2505823', '2505826', '2505828', '2505832', '2505834', '2505835', '2505836', '2505839', '2505841', '2505843', '2505844', '2505846', '2505848', '2505850', '2505853', '2505855', '2505859', '2505864', '2505867', '2505868', '2505869', '2505873', '2505877', '2505881', '2505883', '2505884', '2505887', '2505888', '2505890', '2505892', '2505894', '2505895', '2505896', '2505900', '2505902', '2505903', '2505905', '2505906', '2505912', '2505914', '2505917', '2505919', '2505921', '2505924', '2505926', '2505927', '2561825', '2561831', '2561848', '2561871', '2561882', '2561896', '2561924', '2561945', '2561959', '2561969', '2562000', '2742889', '2742892', '2742916', '2742921', '2742926', '2742927', '2742930', '2742935', '2742937', '2743145', '2743147', '2743149', '2743152', '2743153', '2743156', '2743157', '2743159', '2773951', '2773954', '2773958', '2773961', '2773963', '2773966', '2774034', '2778298', '2778302', '2778304', '2778305', '2778307', '2778309', '2778310', '2778313', '2778315', '2778316', '2779033', '2779041', '2779043', '2779044', '2779045', '2779048', '2779050', '2779053', '2779054', '2779055', '2801156', '2806588', '2806591', '2806596', '2806607', '2806616', '2806627', '2806632', '2806635', '2806637', '2825617', '2825622', '2825626', '2825628', '2825631', '2825633', '2825639', '2825641', '2871591', '2871639', '2871642', '2871644', '2871662', '2871697', '2871700', '2872898', '2872900', '2872901', '2872904', '2872906', '2872909', '2872911', '2872912', '2872914', '2872916', '2872920', '2872923', '2872928', '2872932', '2872934', '2872936', '2872937', '2872938', '2872939', '2872941', '2872944', '2872948', '2872950', '2872951', '2872953', '2872959', '2872961', '2872967', '2872969', '2872971', '2872974', '2872979', '2872982', '2872983', '2872987', '2872988', '2872989', '2872993', '2872996', '2872998', '2873000', '2873002', '2873003', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3104511', '2223056', '2223081', '2223084', '2223088', '2223094', '2223100', '2224626', '2224627', '2224628', '2224629', '2224630', '2224631', '2224632', '2224633', '2224634', '2224635', '2224636', '2224637', '2224638', '2224639', '2224640', '2224652', '2224653', '2224654', '2224655', '2224656', '2224657', '2224658', '2224659', '2224660', '2224661', '2224662', '2224663', '2224664', '2224665', '2224666', '2224667', '2224668', '2224669', '2224670', '2224671', '2224672', '2224673', '2224674', '2224675', '2224676', '2224677', '2224678', '2224679', '2224680', '2224681', '2224682', '2224683', '2224684', '2224685', '2224686', '2224687', '2224688', '2224689', '2224690', '2224691', '2224692', '2224693', '2224694', '2224695', '2224696', '2224697', '2224698', '2224699', '2224700', '2224701', '2224702', '2224703', '2224704', '2224705', '2224706', '2224707', '2224708', '2224709', '2224710', '2224711', '2224712', '2224713', '2224714', '2224715', '2224716', '2224717', '2224718', '2224719', '2224720', '2224721', '2224722', '2224723', '2224724', '2224725', '2224726', '2224727', '2224728', '2224729', '2224730', '2224731', '2224732', '2224733', '2224734', '2224735', '2224736', '2224737', '2224738', '2224739', '2224740', '2224741', '2224742', '2224743', '2224744', '2224745', '2224746', '2224747', '2224748', '2224749', '2224750', '2224751', '2224752', '2224753', '2224754', '2224755', '2224756', '2224757', '2224758', '2224759', '2224760', '2224761', '2224762', '2224763', '2224764', '2224765', '2224766', '2224767', '2224768', '2224769', '2224770', '2224771', '2224772', '2224773', '2224774', '2224775', '2224776', '2224777', '2224778', '2224779', '2224780', '2224781', '2224782', '2224783', '2224784', '2224785', '2224786', '2224787', '2224788', '2224789', '2224790', '2224791', '2224792', '2224793', '2224794', '2224795', '2224796', '2224797', '2224798', '2224799', '2224800', '2224801', '2224802', '2224803', '2224804', '2224805', '2224806', '2224807', '2224808', '2224809', '2224810', '2224811', '2224812', '2224813', '2224814', '2224815', '2224816', '2224817', '2224818', '2224819', '2224820', '2224821', '2224822', '2224823', '2224824', '2224825', '2224826', '2224827', '2224828', '2224829', '2224830', '2224831', '2224832', '2224833', '2224834', '2224835', '2224836', '2224837', '2224838', '2224839', '2224840', '2224841', '2224842', '2224843', '2224844', '2224845', '2224846', '2224847', '2224848', '2224849', '2224850', '2224851', '2224852', '2224853', '2224854', '2224855', '2224856', '2224857', '2224858', '2224859', '2224860', '2224861', '2224862', '2224863', '2224864', '2224865', '2224866', '2224867', '2224868', '2224869', '2224870', '2224871', '2224872', '2224873', '2224874', '2224875', '2224876', '2224877', '2224878', '2224879', '2224880', '2224881', '2224882', '2224883', '2224884', '2224885', '2224886', '2224887', '2224888', '2224889', '2224890', '2224891', '2224892', '2224893', '2224894', '2224895', '2224896', '2224897', '2224898', '2224899', '2224900', '2224901', '2224902', '2224903', '2224904', '2224905', '2224906', '2224907', '2224908', '2224909', '2224910', '2224911', '2224912', '2224913', '2224914', '2224915', '2224916', '2224917', '2224918', '2224919', '2224920', '2224921', '2224922', '2224923', '2224924', '2224925', '2224926', '2224927', '2224928', '2224929', '2224930', '2224931', '2224932', '2224933', '2224934', '2224935', '2224936', '2224937', '2224938', '2224939', '2224940', '2224941', '2224942', '2224943', '2224944', '2224945', '2224946', '2224947', '2224948', '2224949', '2224950', '2224951', '2224952', '2224953', '2224954', '2224955', '2224956', '2224957', '2224958', '2224959', '2224960', '2224961', '2224962', '2224963', '2224964', '2224965', '2224966', '2224967', '2224968', '2224969', '2224970', '2224971', '2224972', '2224973', '2224974', '2224975', '2224976', '2224977', '2224978', '2224979', '2224980', '2224981', '2224982', '2224983', '2224984', '2224985', '2224986', '2224987', '2224988', '2224989', '2224990', '2224991', '2224992', '2224993', '2224994', '2224995', '2224996', '2224997', '2224998', '2224999', '2225000', '2225001', '2225002', '2225003', '2225004', '2225005', '2225006', '2225007', '2225008', '2225009', '2225010', '2225011', '2225012', '2225014', '2225015', '2225016', '2225017', '2225018', '2225019', '2225020', '2225021', '2225022', '2225023', '2225024', '2225025', '2225026', '2225027', '2225028', '2225029', '2225030', '2225031', '2225032', '2225033', '2225034', '2225035', '2225036', '2225037', '2225038', '2225039', '2225040', '2225041', '2225042', '2225043', '2225044', '2225045', '2225046', '2225047', '2225048', '2225049', '2225050', '2225051', '2225052', '2225053', '2225054', '2225055', '2225056', '2225057', '2225058', '2225059', '2225060', '2225061', '2225062', '2225063', '2225064', '2225065', '2225066', '2225067', '2225068', '2225069', '2225070', '2225071', '2225072', '2225073', '2225074', '2225075', '2225076', '2225077', '2225078', '2225079', '2225080', '2225081', '2225082', '2225083', '2225084', '2225085', '2225086', '2225087', '2225088', '2225089', '2225090', '2225091', '2225092', '2225093', '2225094', '2225095', '2225096', '2225097', '2225098', '2225099', '2225100', '2225101', '2225102', '2225103', '2225104', '2225105', '2225106', '2225107', '2225108', '2225109', '2225110', '2225111', '2225112', '2225113', '2225114', '2225115', '2225116', '2225117', '2225118', '2225119', '2225120', '2225121', '2225122', '2225123', '2225124', '2225125', '2225126', '2225127', '2225128', '2225129', '2225130', '2244128', '2244129', '2244130', '2244131', '2244132', '2244133', '2244134', '2244135', '2244136', '2244137', '2244138', '2244139', '2244140', '2244141', '2244142', '2244143', '2244144', '2244145', '2244146', '2244147', '2244148', '2244149', '2244150', '2244151', '2244152', '2244153', '2244154', '2244155', '2244156', '2244157', '2244158', '2244159', '2244160', '2244161', '2244162', '2244163', '2244164', '2244165', '2244166', '2244167', '2244168', '2244169', '2244170', '2244171', '2244172', '2244173', '2244174', '2244175', '2244176', '2244177', '2244178', '2244179', '2244180', '2244181', '2244182', '2244183', '2244184', '2244185', '2244186', '2244187', '2244188', '2244189', '2244190', '2244191', '2244192', '2244193', '2244194', '2244195', '2244196', '2244197', '2244198', '2244199', '2244200', '2244201', '2244202', '2244203', '2244204', '2244205', '2244206', '2244207', '2244208', '2244209', '2244210', '2244211', '2244212', '2244213', '2244214', '2244215', '2244216', '2244217', '2244218', '2244219', '2244220', '2244221', '2244222', '2244223', '2244224', '2244225', '2244226', '2244227', '2244228', '2244229', '2244230', '2244232', '2244233', '2244234', '2244235', '2244236', '2244237', '2244238', '2244239', '2244240', '2244241', '2244242', '2244243', '2244244', '2244245', '2244246', '2244247', '2244248', '2244249', '2244250', '2244251', '2244252', '2244253', '2244254', '2244255', '2244256', '2244257', '2244258', '2244259', '2244260', '2244261', '2244262', '2244263', '2244264', '2244265', '2244266', '2244267', '2244268', '2244269', '2244270', '2244271', '2244272', '2244273', '2244274', '2244275', '2244276', '2244277', '2244278', '2244279', '2244280', '2244281', '2244282', '2244283', '2244284', '2244285', '2244286', '2244287', '2244288', '2244289', '2244290', '2244291', '2244292', '2244293', '2244294', '2244295', '2244296', '2244297', '2244298', '2244299', '2244300', '2244301', '2244302', '2244303', '2244304', '2244305', '2244306', '2244307', '2244308', '2244309', '2244310', '2244311', '2244312', '2244313', '2244314', '2244315', '2244316', '2244317', '2244318', '2244319', '2244320', '2244321', '2244322', '2244323', '2244324', '2244325', '2244326', '2244327', '2244328', '2244329', '2244330', '2244331', '2244332', '2244333', '2244334', '2244335', '2244336', '2244337', '2244338', '2244339', '2244340', '2244341', '2244342', '2244343', '2244344', '2244345', '2244346', '2244347', '2244348', '2244349', '2244350', '2244351', '2244352', '2244353', '2244354', '2244355', '2244356', '2244357', '2244358', '2244359', '2244360', '2244361', '2244362', '2244363', '2244364', '2244365', '2244366', '2244367', '2244368', '2244369', '2244370', '2244371', '2244372', '2244373', '2244374', '2244375', '2244376', '2244377', '2244378', '2244379', '2244380', '2244381', '2244382', '2244383', '2244384', '2244385', '2244386', '2244387', '2244388', '2244389', '2244390', '2244391', '2244392', '2244393', '2244394', '2244395', '2244396', '2244397', '2244398', '2244399', '2244400', '2244401', '2244402', '2244403', '2244404', '2244405', '2244406', '2244407', '2244408', '2244409', '2244410', '2244411', '2244412', '2244413', '2244414', '2244415', '2244416', '2244417', '2244418', '2244419', '2244420', '2244421', '2244422', '2244423', '2244424', '2244425', '2244426', '2244427', '2244428', '2244429', '2244430', '2244431', '2244432', '2244433', '2244434', '2244435', '2244436', '2244437', '2244438', '2244439', '2244440', '2244441', '2244442', '2244443', '2244444', '2244445', '2244446', '2244447', '2244448', '2244449', '2244450', '2244451', '2244452', '2244453', '2244454', '2244455', '2244456', '2244457', '2244458', '2244459', '2244460', '2244461', '2244462', '2244463', '2244464', '2244465', '2416408', '2416410', '2416413', '2416419', '2416420', '2416422', '2416423', '2416427', '2416429', '2416431', '2416437', '2416439', '2416445', '2416447', '2416448', '2416450', '2416451', '2416452', '2416492', '2604355', '2806580', '2806601', '2806609', '2806620', '2806649', '3029012', '3029014', '3029015', '3029018', '3029020', '3029022', '3029023', '3029024', '3029025', '3029027', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3038792', '3038797', '3038799', '3038802', '3038810', '3038813', '3038815', '3038820', '3038823', '3038824', '3038833', '3038834', '3038836', '3038837', '3038838', '3038839', '3038841', '3038842', '3038843', '3038844', '3038845', '3038846', '3038849', '3038851', '3038860', '3038861', '3038862', '3038863', '3038864', '3038865', '3065554', '3065556', '3065559', '3065563', '3065567', '3065571', '3065586', '3065588', '3065594', '3065598', '3065601', '3065606', '3065613', '3065627', '3065628', '3065631', '3065635', '3065638', '3065639', '3065642', '3104826', '3104831', '3104832', '3104833', '3104834', '3104835', '3104836', '3104838', '3104840', '3104841', '3104844', '3104845', '3104847', '3104849', '3104850', '3104852', '3104854', '3104857', '3104861', '3104862', '3104865', '3104868', '3104871', '3104873', '3104876', '3104877', '3104879', '3104880', '3104881', '3104888', '3104950', '3104953', '3104954', '3104955', '3104956', '3104958', '3104961', '3104963', '3104965', '3104970', '3104971', '3104972', '3104973', '3104975', '3104981', '3104982', '3104984', '3104993', '3104999')


SELECT profile_old_value, profile_new_value
FROM history_profiles_change
WHERE client_id = 625
      AND history_profiles_change.is_creation = false
      AND history_profiles_change.created_at >= '2021-02-15'
      AND history_profiles_change.created_at <= '2021-02-21'
      AND history_profiles_change.profile_id in ('1106537', '2102691', '2103168', '2142544', '2142550', '2142559', '2142572', '2142579', '2142581', '2142585', '2142592', '2142604', '2142607', '2142618', '2142625', '2142635', '2142640', '2142648', '2142653', '2142657', '2142660', '2142668', '2142675', '2142682', '2142684', '2178182', '2178183', '2178184', '2178185', '2178186', '2178555', '2178557', '2178558', '2178560', '2178561', '2178563', '2178564', '2178565', '2178566', '2178567', '2178568', '2178571', '2178572', '2178573', '2178574', '2178575', '2178576', '2178577', '2178578', '2178579', '2178580', '2178581', '2178582', '2178583', '2178584', '2178585', '2178586', '2178587', '2178588', '2178589', '2178590', '2178591', '2178592', '2178593', '2178594', '2178595', '2178596', '2178597', '2178598', '2178599', '2181747', '2181890', '2181896', '2181898', '2181899', '2181901', '2181903', '2181905', '2181906', '2181907', '2181908', '2182765', '2183654', '2183656', '2183658', '2183660', '2183661', '2183662', '2183663', '2183664', '2183665', '2183666', '2183667', '2183668', '2183669', '2183671', '2183672', '2183673', '2183674', '2183675', '2183676', '2183677', '2186913', '2187560', '2188345', '2188473', '2188478', '2188480', '2188481', '2188483', '2188484', '2188485', '2188488', '2188489', '2188490', '2188491', '2188493', '2188495', '2188496', '2188497', '2188499', '2188500', '2188501', '2188502', '2188503', '2188504', '2188507', '2188509', '2199020', '2199022', '2199025', '2199026', '2199028', '2199032', '2199034', '2199035', '2199038', '2199039', '2201431', '2201432', '2201433', '2201437', '2201438', '2201439', '2201440', '2201441', '2201442', '2204557', '2205103', '2205104', '2205105', '2205106', '2205107', '2205108', '2205109', '2205110', '2205111', '2205112', '2205113', '2205114', '2205115', '2205116', '2205117', '2205118', '2205119', '2205120', '2205121', '2205122', '2205123', '2205124', '2205125', '2205126', '2238806', '2238807', '2238809', '2238810', '2238811', '2238812', '2238813', '2238814', '2238815', '2238816', '2238817', '2238818', '2238819', '2238820', '2238821', '2238827', '2242744', '2242852', '2242855', '2242859', '2242862', '2242866', '2242869', '2242871', '2242872', '2242876', '2242879', '2242881', '2242884', '2242885', '2242887', '2242891', '2242893', '2242894', '2242896', '2242906', '2242996', '2242997', '2242999', '2243005', '2243457', '2243458', '2243502', '2243507', '2243511', '2243513', '2243517', '2243519', '2243521', '2243524', '2243633', '2243635', '2243638', '2243639', '2243642', '2243643', '2243645', '2243648', '2243650', '2276971', '2276972', '2276973', '2276974', '2276975', '2276976', '2276977', '2276978', '2276979', '2276981', '2505635', '2505636', '2505637', '2505638', '2505640', '2505690', '2505691', '2505694', '2505695', '2505710', '2505734', '2505737', '2505739', '2505741', '2505742', '2505744', '2505747', '2505750', '2505753', '2505758', '2505759', '2505760', '2505764', '2505766', '2505769', '2505792', '2505798', '2505799', '2505813', '2505816', '2505820', '2505822', '2505823', '2505826', '2505828', '2505832', '2505834', '2505835', '2505836', '2505839', '2505841', '2505843', '2505844', '2505846', '2505848', '2505850', '2505853', '2505855', '2505859', '2505864', '2505867', '2505868', '2505869', '2505873', '2505877', '2505881', '2505883', '2505884', '2505887', '2505888', '2505890', '2505892', '2505894', '2505895', '2505896', '2505900', '2505902', '2505903', '2505905', '2505906', '2505912', '2505914', '2505917', '2505919', '2505921', '2505924', '2505926', '2505927', '2561825', '2561831', '2561848', '2561871', '2561882', '2561896', '2561924', '2561945', '2561959', '2561969', '2562000', '2742889', '2742892', '2742916', '2742921', '2742926', '2742927', '2742930', '2742935', '2742937', '2743145', '2743147', '2743149', '2743152', '2743153', '2743156', '2743157', '2743159', '2773951', '2773954', '2773958', '2773961', '2773963', '2773966', '2774034', '2778298', '2778302', '2778304', '2778305', '2778307', '2778309', '2778310', '2778313', '2778315', '2778316', '2779033', '2779041', '2779043', '2779044', '2779045', '2779048', '2779050', '2779053', '2779054', '2779055', '2801156', '2806588', '2806591', '2806596', '2806607', '2806616', '2806627', '2806632', '2806635', '2806637', '2825617', '2825622', '2825626', '2825628', '2825631', '2825633', '2825639', '2825641', '2871591', '2871639', '2871642', '2871644', '2871662', '2871697', '2871700', '2872898', '2872900', '2872901', '2872904', '2872906', '2872909', '2872911', '2872912', '2872914', '2872916', '2872920', '2872923', '2872928', '2872932', '2872934', '2872936', '2872937', '2872938', '2872939', '2872941', '2872944', '2872948', '2872950', '2872951', '2872953', '2872959', '2872961', '2872967', '2872969', '2872971', '2872974', '2872979', '2872982', '2872983', '2872987', '2872988', '2872989', '2872993', '2872996', '2872998', '2873000', '2873002', '2873003', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3104511', '2223056', '2223081', '2223084', '2223088', '2223094', '2223100', '2224626', '2224627', '2224628', '2224629', '2224630', '2224631', '2224632', '2224633', '2224634', '2224635', '2224636', '2224637', '2224638', '2224639', '2224640', '2224652', '2224653', '2224654', '2224655', '2224656', '2224657', '2224658', '2224659', '2224660', '2224661', '2224662', '2224663', '2224664', '2224665', '2224666', '2224667', '2224668', '2224669', '2224670', '2224671', '2224672', '2224673', '2224674', '2224675', '2224676', '2224677', '2224678', '2224679', '2224680', '2224681', '2224682', '2224683', '2224684', '2224685', '2224686', '2224687', '2224688', '2224689', '2224690', '2224691', '2224692', '2224693', '2224694', '2224695', '2224696', '2224697', '2224698', '2224699', '2224700', '2224701', '2224702', '2224703', '2224704', '2224705', '2224706', '2224707', '2224708', '2224709', '2224710', '2224711', '2224712', '2224713', '2224714', '2224715', '2224716', '2224717', '2224718', '2224719', '2224720', '2224721', '2224722', '2224723', '2224724', '2224725', '2224726', '2224727', '2224728', '2224729', '2224730', '2224731', '2224732', '2224733', '2224734', '2224735', '2224736', '2224737', '2224738', '2224739', '2224740', '2224741', '2224742', '2224743', '2224744', '2224745', '2224746', '2224747', '2224748', '2224749', '2224750', '2224751', '2224752', '2224753', '2224754', '2224755', '2224756', '2224757', '2224758', '2224759', '2224760', '2224761', '2224762', '2224763', '2224764', '2224765', '2224766', '2224767', '2224768', '2224769', '2224770', '2224771', '2224772', '2224773', '2224774', '2224775', '2224776', '2224777', '2224778', '2224779', '2224780', '2224781', '2224782', '2224783', '2224784', '2224785', '2224786', '2224787', '2224788', '2224789', '2224790', '2224791', '2224792', '2224793', '2224794', '2224795', '2224796', '2224797', '2224798', '2224799', '2224800', '2224801', '2224802', '2224803', '2224804', '2224805', '2224806', '2224807', '2224808', '2224809', '2224810', '2224811', '2224812', '2224813', '2224814', '2224815', '2224816', '2224817', '2224818', '2224819', '2224820', '2224821', '2224822', '2224823', '2224824', '2224825', '2224826', '2224827', '2224828', '2224829', '2224830', '2224831', '2224832', '2224833', '2224834', '2224835', '2224836', '2224837', '2224838', '2224839', '2224840', '2224841', '2224842', '2224843', '2224844', '2224845', '2224846', '2224847', '2224848', '2224849', '2224850', '2224851', '2224852', '2224853', '2224854', '2224855', '2224856', '2224857', '2224858', '2224859', '2224860', '2224861', '2224862', '2224863', '2224864', '2224865', '2224866', '2224867', '2224868', '2224869', '2224870', '2224871', '2224872', '2224873', '2224874', '2224875', '2224876', '2224877', '2224878', '2224879', '2224880', '2224881', '2224882', '2224883', '2224884', '2224885', '2224886', '2224887', '2224888', '2224889', '2224890', '2224891', '2224892', '2224893', '2224894', '2224895', '2224896', '2224897', '2224898', '2224899', '2224900', '2224901', '2224902', '2224903', '2224904', '2224905', '2224906', '2224907', '2224908', '2224909', '2224910', '2224911', '2224912', '2224913', '2224914', '2224915', '2224916', '2224917', '2224918', '2224919', '2224920', '2224921', '2224922', '2224923', '2224924', '2224925', '2224926', '2224927', '2224928', '2224929', '2224930', '2224931', '2224932', '2224933', '2224934', '2224935', '2224936', '2224937', '2224938', '2224939', '2224940', '2224941', '2224942', '2224943', '2224944', '2224945', '2224946', '2224947', '2224948', '2224949', '2224950', '2224951', '2224952', '2224953', '2224954', '2224955', '2224956', '2224957', '2224958', '2224959', '2224960', '2224961', '2224962', '2224963', '2224964', '2224965', '2224966', '2224967', '2224968', '2224969', '2224970', '2224971', '2224972', '2224973', '2224974', '2224975', '2224976', '2224977', '2224978', '2224979', '2224980', '2224981', '2224982', '2224983', '2224984', '2224985', '2224986', '2224987', '2224988', '2224989', '2224990', '2224991', '2224992', '2224993', '2224994', '2224995', '2224996', '2224997', '2224998', '2224999', '2225000', '2225001', '2225002', '2225003', '2225004', '2225005', '2225006', '2225007', '2225008', '2225009', '2225010', '2225011', '2225012', '2225014', '2225015', '2225016', '2225017', '2225018', '2225019', '2225020', '2225021', '2225022', '2225023', '2225024', '2225025', '2225026', '2225027', '2225028', '2225029', '2225030', '2225031', '2225032', '2225033', '2225034', '2225035', '2225036', '2225037', '2225038', '2225039', '2225040', '2225041', '2225042', '2225043', '2225044', '2225045', '2225046', '2225047', '2225048', '2225049', '2225050', '2225051', '2225052', '2225053', '2225054', '2225055', '2225056', '2225057', '2225058', '2225059', '2225060', '2225061', '2225062', '2225063', '2225064', '2225065', '2225066', '2225067', '2225068', '2225069', '2225070', '2225071', '2225072', '2225073', '2225074', '2225075', '2225076', '2225077', '2225078', '2225079', '2225080', '2225081', '2225082', '2225083', '2225084', '2225085', '2225086', '2225087', '2225088', '2225089', '2225090', '2225091', '2225092', '2225093', '2225094', '2225095', '2225096', '2225097', '2225098', '2225099', '2225100', '2225101', '2225102', '2225103', '2225104', '2225105', '2225106', '2225107', '2225108', '2225109', '2225110', '2225111', '2225112', '2225113', '2225114', '2225115', '2225116', '2225117', '2225118', '2225119', '2225120', '2225121', '2225122', '2225123', '2225124', '2225125', '2225126', '2225127', '2225128', '2225129', '2225130', '2244128', '2244129', '2244130', '2244131', '2244132', '2244133', '2244134', '2244135', '2244136', '2244137', '2244138', '2244139', '2244140', '2244141', '2244142', '2244143', '2244144', '2244145', '2244146', '2244147', '2244148', '2244149', '2244150', '2244151', '2244152', '2244153', '2244154', '2244155', '2244156', '2244157', '2244158', '2244159', '2244160', '2244161', '2244162', '2244163', '2244164', '2244165', '2244166', '2244167', '2244168', '2244169', '2244170', '2244171', '2244172', '2244173', '2244174', '2244175', '2244176', '2244177', '2244178', '2244179', '2244180', '2244181', '2244182', '2244183', '2244184', '2244185', '2244186', '2244187', '2244188', '2244189', '2244190', '2244191', '2244192', '2244193', '2244194', '2244195', '2244196', '2244197', '2244198', '2244199', '2244200', '2244201', '2244202', '2244203', '2244204', '2244205', '2244206', '2244207', '2244208', '2244209', '2244210', '2244211', '2244212', '2244213', '2244214', '2244215', '2244216', '2244217', '2244218', '2244219', '2244220', '2244221', '2244222', '2244223', '2244224', '2244225', '2244226', '2244227', '2244228', '2244229', '2244230', '2244232', '2244233', '2244234', '2244235', '2244236', '2244237', '2244238', '2244239', '2244240', '2244241', '2244242', '2244243', '2244244', '2244245', '2244246', '2244247', '2244248', '2244249', '2244250', '2244251', '2244252', '2244253', '2244254', '2244255', '2244256', '2244257', '2244258', '2244259', '2244260', '2244261', '2244262', '2244263', '2244264', '2244265', '2244266', '2244267', '2244268', '2244269', '2244270', '2244271', '2244272', '2244273', '2244274', '2244275', '2244276', '2244277', '2244278', '2244279', '2244280', '2244281', '2244282', '2244283', '2244284', '2244285', '2244286', '2244287', '2244288', '2244289', '2244290', '2244291', '2244292', '2244293', '2244294', '2244295', '2244296', '2244297', '2244298', '2244299', '2244300', '2244301', '2244302', '2244303', '2244304', '2244305', '2244306', '2244307', '2244308', '2244309', '2244310', '2244311', '2244312', '2244313', '2244314', '2244315', '2244316', '2244317', '2244318', '2244319', '2244320', '2244321', '2244322', '2244323', '2244324', '2244325', '2244326', '2244327', '2244328', '2244329', '2244330', '2244331', '2244332', '2244333', '2244334', '2244335', '2244336', '2244337', '2244338', '2244339', '2244340', '2244341', '2244342', '2244343', '2244344', '2244345', '2244346', '2244347', '2244348', '2244349', '2244350', '2244351', '2244352', '2244353', '2244354', '2244355', '2244356', '2244357', '2244358', '2244359', '2244360', '2244361', '2244362', '2244363', '2244364', '2244365', '2244366', '2244367', '2244368', '2244369', '2244370', '2244371', '2244372', '2244373', '2244374', '2244375', '2244376', '2244377', '2244378', '2244379', '2244380', '2244381', '2244382', '2244383', '2244384', '2244385', '2244386', '2244387', '2244388', '2244389', '2244390', '2244391', '2244392', '2244393', '2244394', '2244395', '2244396', '2244397', '2244398', '2244399', '2244400', '2244401', '2244402', '2244403', '2244404', '2244405', '2244406', '2244407', '2244408', '2244409', '2244410', '2244411', '2244412', '2244413', '2244414', '2244415', '2244416', '2244417', '2244418', '2244419', '2244420', '2244421', '2244422', '2244423', '2244424', '2244425', '2244426', '2244427', '2244428', '2244429', '2244430', '2244431', '2244432', '2244433', '2244434', '2244435', '2244436', '2244437', '2244438', '2244439', '2244440', '2244441', '2244442', '2244443', '2244444', '2244445', '2244446', '2244447', '2244448', '2244449', '2244450', '2244451', '2244452', '2244453', '2244454', '2244455', '2244456', '2244457', '2244458', '2244459', '2244460', '2244461', '2244462', '2244463', '2244464', '2244465', '2416408', '2416410', '2416413', '2416419', '2416420', '2416422', '2416423', '2416427', '2416429', '2416431', '2416437', '2416439', '2416445', '2416447', '2416448', '2416450', '2416451', '2416452', '2416492', '2604355', '2806580', '2806601', '2806609', '2806620', '2806649', '3029012', '3029014', '3029015', '3029018', '3029020', '3029022', '3029023', '3029024', '3029025', '3029027', '3029910', '3029911', '3029912', '3029913', '3029914', '3029915', '3029916', '3029917', '3029918', '3029919', '3029920', '3029921', '3029922', '3029923', '3029924', '3029925', '3029926', '3029927', '3029928', '3029929', '3029930', '3029931', '3029932', '3029933', '3029934', '3029935', '3029936', '3029937', '3029938', '3029939', '3029940', '3029941', '3029942', '3029943', '3029944', '3029945', '3029946', '3029947', '3029948', '3029949', '3029950', '3029951', '3029952', '3029953', '3029954', '3029955', '3029956', '3029957', '3029958', '3029959', '3029960', '3029961', '3029962', '3029963', '3029964', '3029965', '3029966', '3029967', '3029968', '3029969', '3029970', '3029971', '3029972', '3029973', '3029974', '3029975', '3029976', '3029977', '3029978', '3029979', '3029980', '3029981', '3029982', '3029983', '3029984', '3029985', '3029986', '3029987', '3029988', '3029989', '3029990', '3029991', '3029992', '3029993', '3029994', '3029995', '3029996', '3029997', '3029998', '3029999', '3030000', '3038792', '3038797', '3038799', '3038802', '3038810', '3038813', '3038815', '3038820', '3038823', '3038824', '3038833', '3038834', '3038836', '3038837', '3038838', '3038839', '3038841', '3038842', '3038843', '3038844', '3038845', '3038846', '3038849', '3038851', '3038860', '3038861', '3038862', '3038863', '3038864', '3038865', '3065554', '3065556', '3065559', '3065563', '3065567', '3065571', '3065586', '3065588', '3065594', '3065598', '3065601', '3065606', '3065613', '3065627', '3065628', '3065631', '3065635', '3065638', '3065639', '3065642', '3104826', '3104831', '3104832', '3104833', '3104834', '3104835', '3104836', '3104838', '3104840', '3104841', '3104844', '3104845', '3104847', '3104849', '3104850', '3104852', '3104854', '3104857', '3104861', '3104862', '3104865', '3104868', '3104871', '3104873', '3104876', '3104877', '3104879', '3104880', '3104881', '3104888', '3104950', '3104953', '3104954', '3104955', '3104956', '3104958', '3104961', '3104963', '3104965', '3104970', '3104971', '3104972', '3104973', '3104975', '3104981', '3104982', '3104984', '3104993', '3104999')




