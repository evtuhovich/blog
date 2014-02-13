---
layout: post
title: Партиционирование
date: 2013-02-24 22:12
comments: true
tags:
- PostgreSQL
- partitioning
---

Я долго считал партиционирование плохой практикой, а само слово не любил из-за кальки с английского, которую крайне
сложно выговорить с первого раза. И если слово «партиционирование» я так с первого раза и не выговариваю, то саму
практику пришлось признать как необходимое и неизбежное зло. Чтобы никто не подумал, что я делаю что-то плохое, я
использую для этого термин «инженерный компромисс», звучит умнее и не так обидно.

<!-- more -->

Если бы партиционирование укладывалось в рамки [официальной документации](http://www.postgresql.org/docs/9.2/static/ddl-partitioning.html),
то и писать бы о нем не стоило. Но есть особенности, которые не сразу ясны из официальной документации, либо, вообще, в ней не
раскрываются.

Сразу скажу, что если есть возможность не делать партиционирование, то лучше его не делать. Зачастую дешевле увеличить
размер памяти у вашего сервера БД, чтобы он начал запросто переваривать большие таблицы. И только когда вы упретесь в
то, что такого количества памяти нет в продаже, стоит приступать к активным действиям.

[Официальной документации](http://www.postgresql.org/docs/9.2/static/ddl-partitioning.html) вполне достаточно для того,
чтобы партиционирование заработало. Более того, все дальнейшие рассуждения буду мало полезными для тех, кто официальную
документацию не читал.

Во-первых, в `CHECK CONSTRAINTS` должны быть IMMUTABLE функции. День у меня ушел на то, чтобы понять, что [TIMESTAMP
WITH TIME ZONE не является IMMUTABLE](http://postgresql.1045698.n5.nabble.com/Constraint-exclusion-can-t-process-simple-constant-expressions-td4329606.html).

Пример того, как выглядит генерация триггера на вставку в партиционированную таблицу. Для этой статьи я добавил
комментарии для больше понятности, но все равно выглядит громоздко.

{% codeblock lang:ruby %}
class CreatePartitionsForArchiveTransfers < ActiveRecord::Migration
  def up
    # Таблица фактов называется archive_transfers, мы разобъем ее на части по месяцам

    start = Date.parse '2011-10-01'
    trigger_parts = []   # здесь будут храниться куски триггера на вставку
    # сгенерируем триггер и таблицы до 2014-09 включительно - 3 года = 36 месяцев
    36.times do |i|
      date = start + i.month
      # таблицы будут иметь названия вида archive_transfers_2013_03
      table_name = "archive_transfers_#{date.strftime('%Y_%m')}"

      # b и e - сокращения от begin и end
      b = "'" + date.to_time_in_current_zone.utc.strftime('%Y-%m-%d %H:%M:%S') + "'"
      e = "'" +
        (date + 1.month).to_time_in_current_zone.utc.strftime('%Y-%m-%d %H:%M:%S') + "'"

      trigger_parts << " ( NEW.created_at >= #{b} AND
               NEW.created_at < #{e} ) THEN
              INSERT INTO #{table_name} VALUES (NEW.*);
      "

      create_table table_name, :options => "inherits (archive_transfers)" do |t|
      end

      # индексы не наследуются, поэтому для каждой
      # дочерней таблицы их надо создавать заново
      add_index table_name, :sender_id
      add_index table_name, :receiver_id

      # для каждой дочерней табилцы создаем проверку,
      # чтобы в нее попадали только нужные данные
      execute "ALTER TABLE #{table_name} ADD CHECK (
        created_at >= #{b} AND
        created_at < #{e})"
    end

    execute %Q(
      CREATE OR REPLACE FUNCTION archive_transfers_insert_trigger()
      RETURNS TRIGGER AS $$
      BEGIN
          IF ) + trigger_parts.join('ELSEIF') +
      %Q(    ELSE
              RAISE EXCEPTION 'Date out of range. Fix the archive_transfers_insert_trigger() function!';
          END IF;
          RETURN NULL;
      END;
      $$
      LANGUAGE plpgsql;
    )

    execute %Q(
      CREATE TRIGGER insert_archive_transfers_trigger
      BEFORE INSERT ON archive_transfers
      FOR EACH ROW EXECUTE PROCEDURE archive_transfers_insert_trigger();)

  end
end
{% endcodeblock %}

После выполнения мы получим 36 новых таблиц в БД и триггер, похожий на этот.

{% codeblock lang:sql %}
CREATE OR REPLACE FUNCTION archive_transfers_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF  ( NEW.created_at >= '2011-09-30 20:00:00' AND
          NEW.created_at < '2011-10-31 20:00:00' ) THEN
         INSERT INTO archive_transfers_2011_10 VALUES (NEW.*);
  ELSEIF ( NEW.created_at >= '2011-10-31 20:00:00' AND
          NEW.created_at < '2011-11-30 20:00:00' ) THEN
         INSERT INTO archive_transfers_2011_11 VALUES (NEW.*);
% здесь пропустим много таких же строчек
  ELSEIF ( NEW.created_at >= '2014-08-31 20:00:00' AND
          NEW.created_at < '2014-09-30 20:00:00' ) THEN
         INSERT INTO archive_transfers_2014_09 VALUES (NEW.*);
  ELSE
     RAISE EXCEPTION 'Date out of range.  Fix the archive_transfers_insert_trigger() function!';
  END IF;
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;

{% endcodeblock %}

При партиционировании перестает работать `RETURNING`, а это значит, что при вставке новой записи нельзя узнать ее
id. Для этого существует [костыль](https://gist.github.com/copiousfreetime/59067), который на каждую вставку делает
дополнительную вставку и удаление, чтобы получить id записи. Я не рискнул использовать его в бою, поскольку у нас и так
очень интенсивная нагрузка на БД.

Более того, надо понимать, что в случае с партиционироваными таблицами, вы можете иметь одинаковые id для разных
записей, так как уникальность id проверяется (если проверяется) только на уровне конкретной дочерней таблицы. Если вы
вставляете данные только в главную таблицу `archive_transfers`, то id гарантированно будут отличаться, потому что
триггер использует sequence от главной таблицы. Но ничего не запрещает вам вставить в дочернюю таблицу данные напрямую.

Какой выигрыш от такого усложнения? Во-первых, вместо одного большого индекса у вас будет теперь много маленьких,
которые помещаются в память. Если вам надо сделать выборку по дате, то seq scan будет идти только по нужным партициям. В
нашем случае, например, все запросы, в основном, делаются по последнему месяцу, поэтому она оказывается в кэше БД и,
самое главное, помещается туда целиком. А как мы знаем, БД для web-проекта либо помещается в память, либо не работает,
но об этом я напишу как-нибудь в другой раз.

Сам понимаю, что получилось немного сумбурно, поэтому с радостью раскрою непонятные вопросы в комментариях.
