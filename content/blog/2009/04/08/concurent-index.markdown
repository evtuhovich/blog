---

title: Конкурентное пересоздание индексов в postgresql
date: 2009-04-08T11:11:00
comments: true
tags:
- PostgreSQL
- индексы
---

На таблице postgresql с большим количеством данных невозможно быстро создать либо пересоздать индекс. При создании
индекса таблица блокируется для операций INSERT, UPDATE и DELETE. В таких случаях может помочь конкурентное создание
индекса. Иногда на postgresql стоит пересоздавать индексы, чтобы уменьшить их фрагментацию (и увеличить скорость).
Создание конкурентного индекса будет частным случаем его пересоздания.

Пусть имеется таблица orders с 1 миллионом записей (приблизительно) в которой хранятся заказы. И в этой таблице есть
поля country_id, region_id, city_id, на которых создан индекс.

``` sql
    # \d orders
                                        Таблица "public.orders"
      Колонка   |             Тип             |                    Модификаторы                     
    ------------+-----------------------------+-----------------------------------------------------
     id         | integer                     | not null default nextval('orders_id_seq'::regclass)
     book_id    | integer                     | 
     created_at | timestamp without time zone | 
     updated_at | timestamp without time zone | 
     country_id | integer                     | 
     region_id  | integer                     | 
     city_id    | integer                     | 
     cost       | numeric                     | 
     shop_id    | integer                     | 
    Индексы:
        "orders_country_region_city" btree (country_id, region_id, city_id)
```

Тогда следующая последовательность действий позволит пересоздать индекс конкурентно

``` sql
    pgq=# CREATE INDEX CONCURRENTLY orders_country_region_city2 ON orders(country_id, region_id, city_id);
    CREATE INDEX
    pgq=# DROP INDEX orders_country_region_city;
    DROP INDEX
    pgq=# ALTER INDEX orders_country_region_city2 RENAME TO orders_country_region_city;
    ALTER INDEX
```

Более подробно о конкурентных индексах [почитать можно на официальном сайте](http://www.postgresql.org/docs/8.3/interactive/sql-createindex.html).

Пока на этом всё, и нескучного вам программирования.
