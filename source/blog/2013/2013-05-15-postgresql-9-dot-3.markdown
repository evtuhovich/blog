---

title: "PostgreSQL 9.3 beta 1 на OSX"
date: 2013-05-15 13:18
comments: true
tags: 
- PostgreSQL
---

Два дня назад, 13 мая, [вышла beta 1 PostgreSQL 9.3](http://www.postgresql.org/about/news/1463/). Во-первых, это хороший
знак, что уже пора обновляться на 9.2, либо выбирать 9.2 как основную БД. 9.3 планируется [зарелизить в третьем квартале
2013 года](http://www.postgresql.org/developer/roadmap/).

Обо всех новых возможностях 9.3 можно почитать на [официальной wiki](http://wiki.postgresql.org/wiki/What%27s_new_in_PostgreSQL_9.3).

Но чтобы не только почитать, но и попробовать, я напишу здесь, как поставить 9.3 beta 1 на OSX.

READMORE

К нашему большому счастью, один из разработчиков PostgreSQL — [Peter Eisentraut](http://petereisentraut.blogspot.ru/)
уже сделал формулу для homebrew, чтобы поставить 9.3.

```

$ brew update

$ brew tap petere/postgresql

$ brew install postgresql-9.3

```

Все эти процедуры никак не угрожают предыдущей версии PostgreSQL, который вы поставили из homebrew.
Далее необходимо создать новый кластер для для 9.3.

```

$ cd /usr/local/Cellar/postgresql-9.3/9.3beta1/bin

$ ./initdb /usr/local/var/postgres-9.3


```

Далее в файле /usr/local/var/postgres-9.3/postgresql.conf поменяйте порт на 5433, если у вас установлена и запущена
другая версия PostgreSQL, чтобы можно было пользоваться одновременно двумя.

```
$ cat /usr/local/var/postgres-9.3/postgresql.conf | grep port
port = 5433                             # (change requires restart)
```

Все, можно запускать.

```

$ /usr/local/Cellar/postgresql-9.3/9.3beta1/bin/pg_ctl \
  -D /usr/local/var/postgres-9.3/ -l /var/log/postgresql-9.3.log start

```

Возможно, у вас не будет хватать прав на /var/log/postgresql-9.3.log, но я уверен, вы с этим справитесь.

Проверим, что все правильно.

```
$ psql -p 5433
Pager usage is off.
psql (9.2.2, server 9.3beta1)
WARNING: psql version 9.2, server version 9.3.
         Some psql features might not work.
Type "help" for help.

brun=# \q
```

Ура, можно экспериментировать. О том, что интересного появилось в 9.3, я расскажу в следующих постах.

*PS* Когда дописал статью, нашел более короткое [руководство от Peter Eisentraut на английском](http://petereisentraut.blogspot.ru/2013/04/installing-multiple-postgresql-versions.html).
