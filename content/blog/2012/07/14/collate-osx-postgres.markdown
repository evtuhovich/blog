---

title: Проблема с сортировкой русских слов в Postgres на OSX
date: 2012-07-14T13:17:00
comments: true
tags:
- PostgreSQL
- osx
---

Я давно мечтаю об Ubuntu, которая работает так же хорошо, как OSX. К несчастью, большинство пользовательских программ в
Ubuntu хуже, чем в OSX, а что касается серверной части - OSX очень сильно отстает от Ubuntu (Debian).

К примеру, по-умолчанию, в Postgresql в OSX сломана сортировка русских слов. Решение я нашел
[здесь](http://chipiga.pp.ua/sql/kak-zastavit-postgresql-pravilno-sortirovat-utf8-kirillitsu-na-mac-os-x/).

<!--more-->

Вкратце, в этой статье вместо сортировки русского языка сделана бинарная сортировка, которая в большинстве случаев
работает.

Вот как это выглядит по-умолчанию.

```sql
SELECT * FROM words ORDER BY word;

  292 | шептать        |     23
  602 | ягнёнок        |     40
  697 | здорово!       |     41
  698 | молодец!       |     41
```

Теперь попробуем исправить эту ситуацию. Вначале сделайте полный дамп кластера командой pg_dumpall. Учтите, что если на
вашей машине много БД с данными, то эта команда может занять продолжительное время.

```sh

$ pg_dumpall > dump.all

```

Далее будем считать, что у вас postgres стоит из homebrew. В противном случае некоторые шаги будут отличаться.
Останавливаем postgresql, переносим старый кластер (на всякий случай).

```sh

$ launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist

$ mv /usr/local/var/postgres /usr/local/var/postgres_old
```

Создает новый кластер с нужными нам настройками локали.

```sh

$ export LC_COLLATE=C
$ unset LC_ALL
$ initdb -D /usr/local/var/postgres
The files belonging to this database system will be owned by user "brun".
This user must also own the server process.

The database cluster will be initialized with locales
  COLLATE:  C
  CTYPE:    ru_RU.UTF-8
  MESSAGES: ru_RU.UTF-8
  MONETARY: ru_RU.UTF-8
  NUMERIC:  ru_RU.UTF-8
  TIME:     ru_RU.UTF-8
The default database encoding has accordingly been set to UTF8.
The default text search configuration will be set to "russian".

```

После этого надо запустить postgres и загрузить в него дамп.

```sh
	$ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
	$ psql postgres < dump.all
	# Если все после этого заработало, то удалите старый кластер. Не забудьте,
  # что там может быть нужный вам postgresql.conf, pg_hba.conf
	$ rm -rf /usr/local/var/postgres_old
```

Проверим, что все заработало.

```sql

SELECT * FROM words ORDER BY word;

  752 | борода         |     44
  695 | браво!         |     41
  748 | брови          |     44
  268 | бросай         |     20

```

Вроде бы победа, но у этой победы странный вкус. Обнаружены проблемы с буквами Ё/ё. Также сортировака учитывает регистр
(и это не обойти). Но это гораздо лучше, чем то, что было до этого.

Обращу внимание, что сортировка в Ubuntu работает правильно по-умолчанию. Человечеству еще предстоит сделать систему,
удобную, как OSX, и с apt-get вместо AppStore.
