---

title: PosgtreSql, миграции и огромные таблицы
date: 2009-03-20T12:34:00
comments: true
tags:
- PostgreSQL
- rails
---

Миграции в rails — это очень правильный инструмент. Правда, иногда случаются казусы, потому что конкретная БД перестает
быть «сферическим конем в вакууме», как только количество данных и нагрузка на нее становится существенной.

Пусть у нас есть таблица posts, в которой 10 миллионов записей. И мы решили добавить в нее поле is_searchable.

```
    $ script/generate migration add_is_searchable_to_posts
```

``` ruby
    class AddIsSearchableToPosts < ActiveRecord::Migration
      def self.up
        add_column :posts, :is_searchable, :boolean, :default => true, :null => false
      end

      def self.down
        remove_column :posts, :is_searchable
      end
    end
```

Если на базе development данных у вас немного, то миграция пройдет замечательно. На production базе она может занять
несколько часов, блокируя таблицу posts. Заглянув в документацию по postgresql и немного подумав, можно переписать эту
миграцию вот так:

``` ruby
    class AddIsSearchableToPosts < ActiveRecord::Migration
      def self.up
        add_column :posts, :is_searchable, :boolean, :null => true
      end

      def self.down
        remove_column :posts, :is_searchable
      end
    end
```

А после этого выполнить следующий скрипт. Выполнить этот же код в миграции нельзя, потому что миграция выполняется
внутри тразнакции, а значит это было бы равносильно первому случаю.

``` ruby
    i = 0
    loop do
      say("Update posts with id #{i}..#{i + 10000}")
      result = execute("UPDATE posts
        SET is_searchable = true WHERE id >= #{i} AND id < #{i + 10000}")
      break if result.cmdtuples == 0
      i += 10000
    end
    execute('ALTER TABLE posts ALTER COLUMN is_searchable SET NOT NULL')
```

Создание поля без присвоения ему значения меняет только метаинформацию о таблице. Серия update'ов, хоть и
создает дополнительную нагрузку на базу, но оставляет приложение работоспособным. А вот один большой update на 10
миллионов записей фактически блокирует таблицу на запись на все время своего исполнения.

Хотя я написал в заголовке PostgreSql, но это правило распространяется на все БД, с которыми я знаком --- MySQL и MS
SQL.
