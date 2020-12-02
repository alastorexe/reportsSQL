
/*
Необходимо выгрузить номера карт, которые заправлялись с 01.11-30.11 от 16 заправок и более
( главное условие чтобы минимум в 1 чеке было от 1500 рублей на топливо и хот дог).

Нужны только номера карт
*/

SELECT cards.uid, count(DISTINCT orders.id) as orders_count
FROM cards
  inner JOIN profiles on profiles.id = cards.profile_id
  inner join orders on orders.card_id = cards.id
  inner join goods_incomes on goods_incomes.order_id = orders.id
  inner join (
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
                       and goods_incomes.goods_id in (
                   1516847,  2305419,  3013460,  1516843,  1516845,  1516848,  2212948,  1516849,  1516851,  1518158,  2107476,  2528930
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
             ) as custom_orders on custom_orders.card_id = cards.id
WHERE cards.client_id = 625
      and goods_incomes.goods_id in (
  1516847,  2305419,  3013460,  1516843,  1516845,  1516848,  2212948,  1516849,  1516851,  1518158,  2107476,  2528930
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
ORDER BY orders.from DESC