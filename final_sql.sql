

-- 1 Имя и Фамилия, телефон покупателей адрес со страной Латвия
SELECT first_name, last_name, phone
  FROM Customers as c join addresses as a on a.customer_id = c.id
   WHERE country = 'Latvia';

-- 2 Первые десять покупателей с адресами
  SELECT *
      FROM customers as c join addresses as a on a.customer_id = c.id
      ORDER BY c.id limit 10;

-- 3 Покупки альбомов ид котых между 7 и 12
  Select s.id, p.artist, p.album, s.price
    FROM Sales as s inner join Product as p on p.id = s.product_id
     WHERE product_id BETWEEN 7 and 12 limit 10;

-- 4 Число покупок тех чье имя начинается с 'B'
  SELECT first_name, last_name, COUNT(s.id) AS sale_count
   FROM Customers as c join sales as s on s.customer_id = c.id
    WHERE first_name LIKE 'B%' GROUP BY first_name, last_name limit 10;

-- 5 20 покупателей чья сумма покупок больше всего
  SELECT distinct customer_id, SUM(price) OVER (PARTITION BY customer_id) AS sum
   FROM Sales ORDER BY sum DESC limit 20;

-- 6 Максимальная и минимальная цена покупок по продуктам
  SELECT DISTINCT product_id, MIN(price) AS min_price, MAX(price) AS max_price
    FROM Sales GROUP BY product_id ORDER BY product_id DESC;

-- 7 какие альбомы покупают со средней ценой покупки больше 25
  WITH avg_sale_price AS (
   SELECT customer_id, AVG(price) as avg_price
    FROM sales GROUP BY customer_id
 ) SELECT DISTINCT p.album, p.artist FROM avg_sale_price AS ap
    JOIN sales AS s ON s.customer_id = ap.customer_id
    JOIN PRODUCT as p ON p.id = s.product_id
    GROUP BY p.album, p.artist, ap.avg_price HAVING ap.avg_price > 25 LIMIT 5;

-- 8 Минимальная и максимальная цена покупки тех кто купил альбомы с наименьшей суммой продажи
   SELECT DISTINCT c.first_name, c.last_name, MIN(price) OVER (PARTITION By customer_id) min_price,
    MAX(price) OVER (PARTITION By customer_id) max_price
    FROM (
     SELECT Product_id, sp.sum_price FROM (
      SELECT DISTINCT product_id, SUM(price) OVER (PARTITION BY product_id) as sum_price
       FROM sales ) AS sp ORDER BY sp.sum_price ) AS prod
    JOIN sales AS s ON s.product_id = prod.product_id JOIN customers as c ON c.id = s.customer_id
    ORDER BY min_price LIMIT 5;

-- 9 Минимальная, максимальная, средняя покупка, число покупок по покупателям
SELECT DISTINCT c.first_name, c.last_name, MIN(price) OVER (PARTITION By customer_id) min_price,
 MAX(price) OVER (PARTITION By customer_id) max_price, AVG(price) OVER (PARTITION By customer_id),
 COUNT(s.id) OVER (PARTITION By customer_id) as count_buys
  FROM sales as s join customers as c On c.id = s.customer_id ORDER BY count_buys DESC limit 5;

-- 10 Топ 5 альбомов с наибольшей суммой продажи при наименьшем числе покупок
SELECT p.album, p.artist FROM (
 SELECT DISTINCT sp.product_id, sum_price, COUNT(s.id) OVER (PARTITION BY sp.product_id) as count_sale
  FROM (
    SELECT DISTINCT product_id, SUM(price) OVER (PARTITION BY product_id)  AS sum_price
     FROM sales ORDER BY sum_price ) AS sp join sales as s on s.product_id = sp.product_id
   ORDER BY count_sale DESC ) AS alb JOIN product as p ON p.id = alb.product_id limit 5;

-- View 1
CREATE VIEW converge AS
   SELECT *
   FROM product
    WHERE artist = 'Converge';

-- View 2
 CREATE VIEW top_prices AS
   SELECT *
   FROM Sales
   WHERE price > 25;
