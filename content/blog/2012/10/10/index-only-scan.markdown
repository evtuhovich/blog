---

title: Index Only Scan в Postgresql 9.2
date: 2012-10-10T13:09:00
comments: true
tags:
- PostgreSQL
- индексы
---

Вообще, сам не узнаю себя, уже ровно месяц прошел с выпуска [Postgresql 9.2](http://www.postgresql.org/docs/9.2/static/release-9-2.html), даже вышло [обновление 9.2.1](http://www.postgresql.org/docs/9.2/static/release-9-2-1.html), исправляющее некоторые баги, а я все еще ничего не написал об этом.

Поэтому сегодня рассказ будет о Index Only Scan — самом заметном, по моему мнению, изменении в 9.2. Кстати, именно это
изменение стоит первым в [Release Notes](http://www.postgresql.org/docs/9.2/static/release-9-2.html), а значит я не
одинок.

<!--more-->

Итак, у нас есть БД Posgresql 9.2 с предварительно отключенным автовакумом.

```

$ cat postgresql.conf | grep autovacuum\ =
autovacuum = off			# Enable autovacuum subprocess?  'on'

$ echo "select version()" | psql
             version
-----------------------------------------------------------------------------
 PostgreSQL 9.2.1 on x86_64-apple-darwin12.2.0, compiled by Apple 
 clang version 4.0 (tags/Apple/clang-421.0.57) (based on LLVM 3.1svn), 64-bit
(1 row)

```

Также у нас есть вот такая таблица `a` с индексом на поле `first_name`.

```

mc=# \d a
         Table "public.a"
   Column    |  Type   | Modifiers 
-------------+---------+-----------
 id          | integer | 
 first_name  | text    | 
 middle_name | text    | 
 last_name   | text    | 
 checked     | boolean | 
 b           | text    | 
Indexes:
    "a_first_name_idx" btree (first_name)

```

Посмотрим, сколько же записей в этой таблице и сколько в ней Иванов.

```sql

select count(*) from a;
 count 
-------
 48596
(1 row)

mc=# select count(*) from a where first_name = 'Иван';
 count 
-------
   371
(1 row)

```

Что же, посмотрим, как Иваны будут извлекаться из БД.

```

explain (analyze true, buffers true) select count(*) from a where first_name = 'Иван';
                                                             QUERY PLAN                                                             
------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=815.89..815.90 rows=1 width=0) (actual time=4.080..4.080 rows=1 loops=1)
   Buffers: shared hit=17
   ->  Bitmap Heap Scan on a  (cost=16.51..814.58 rows=525 width=0) (actual time=0.235..0.471 rows=371 loops=1)
         Recheck Cond: (first_name = 'Иван'::text)
         Buffers: shared hit=17
         ->  Bitmap Index Scan on a_first_name_idx  (cost=0.00..16.38 rows=525 width=0) (actual time=0.212..0.212 rows=742 loops=1)
               Index Cond: (first_name = 'Иван'::text)
               Buffers: shared hit=7
 Total runtime: 4.133 ms
(9 rows)

```

Как мы видем, вначале Иваны вытаскиваются из индекса (`Bitmap Index Scan`), а потом pg лезет в саму таблицу
(`Bitmap Heap Scan`), чтобы проверить, есть ли такие записи на самом деле. Дело в том, что Postgresql —
[версионная БД](http://www.postgresql.org/docs/9.2/static/mvcc-intro.html), то есть хранит разные версии строк, чтобы не
блокировать читающие процессы. И информация о том, сущетсвует ли данная версия строки в данной транзакции хранится
только в самой таблице, индексы же могут хранить ссылки на невидимые в данной транзакции строки.

В версии 9.2 pg хранит данные о видимости в так называемой «карте видимости» (visibility map), которая представляет из
себя массив битов — по одному биту на каждую страницу pg (8 кб). Если все строки на этой странице видимы, то этот бит
выставляется, и это означает, что нет необходимости проверять видимость какой-то строки, найденной в индексе.

Поскольку vacuum как раз занимается тем, что чистит старые строки, то он же и обновляет visibility map. Поэтому сделаем
вакум на таблице `a` и повторим наш запрос.

```
mc=# vacuum a;
VACUUM
mc=# explain (analyze true, buffers true) select count(*) from a where first_name = 'Иван';
                                                             QUERY PLAN                                                              
-------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=417.30..417.31 rows=1 width=0) (actual time=0.304..0.304 rows=1 loops=1)
   Buffers: shared hit=9
   ->  Index Only Scan using a_first_name_idx on a  (cost=0.00..416.69 rows=243 width=0) (actual time=0.095..0.224 rows=371 loops=1)
         Index Cond: (first_name = 'Иван'::text)
         Heap Fetches: 0
         Buffers: shared hit=9
 Total runtime: 0.342 ms
(7 rows)

```

И да, мы получили другой план запроса, как и ожидали. Понятно, что index only scan может ускорить запросы только по тем
таблицам, которые достаточно редко обновляются.

Что же касается обновления на новую версию, то мы, как обычно, решили повременить пару месяцев, пока 9.2 окончательно
стабилизируется. Чтобы [не случилось чего-нибудь такого](http://www.sql.ru/forum/actualthread.aspx?tid=973589).

[Ссылка на Index Only Scan в wiki postgresql](http://wiki.postgresql.org/wiki/Index-only_scans).
