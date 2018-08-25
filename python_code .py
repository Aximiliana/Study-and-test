import os
import logging

import psycopg2
import psycopg2.extensions
import pandas as pd
import numpy as np


logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Задание по Psycopg2
# --------------------------------------------------------------

logger.info("Создаём подключёние к Postgres")
params = {
    "host": '0.0.0.0',
    "port": '5432',
    "user": 'postgres'
}
conn = psycopg2.connect(**params)

# дополнительные настройки
psycopg2.extensions.register_type(
    psycopg2.extensions.UNICODE,
    conn
)
conn.set_isolation_level(
    psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT
)
cursor = conn.cursor()

# read tables

products = pd.read_sql('SELECT * FROM product', conn)
logger.info("Таблица продуктов")
print(products.head())

sales = pd.read_sql('SELECT * FROM sales', conn)
logger.info("Таблица продаж")
print(sales.head())

customers = pd.read_sql('SELECT * FROM customers', conn)
logger.info("Таблица покупателей")
print(customers.head())

addresses = pd.read_sql('SELECT * FROM addresses', conn)
logger.info("Таблица адресов")
print(addresses.head())

#Покупатели у которых есть адрес со страной Латвия
query1 = customers.merge(addresses[addresses.country == 'Latvia'][['customer_id']], how='inner', left_on='id', right_on='customer_id')[['first_name', 'last_name']]
print(query1.head())

#Джойн покупателей и их адресов
query2 = customers.merge(addresses, how='inner', left_on='id', right_on='customer_id').head()
print(query2.head())

#Покупки альбомов ид котых между 7 и 12
query3 = sales[sales['product_id'].between(7, 12, inclusive=True)]
print(query3.head())

#Максимальная и минимальная цена покупок по продуктам
min_max_prods = sales.groupby(['product_id']).agg({'price': ['min', 'max']}).sort_values(by='product_id', ascending=False).head(5)
print(min_max_prods.head())

#20 покупателей чья сумма покупок больше всего
sum_customer_buys = sales.groupby(['customer_id']).agg({'price' : ['sum']}).sort_values(by='customer_id', ascending=False).head(20)
print(sum_customer_buys.head(20))
