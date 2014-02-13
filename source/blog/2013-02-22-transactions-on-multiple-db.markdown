---
layout: post
title: Транзакции и несколько БД
date: 2013-02-22 00:38
comments: true
tags:
- rspec
---

Иногда так случается, что на проекте необходимо использовать более одного сервера баз данных. Оказывается, в rails можно
достаточно удобно поддерживать актуальность нескольких БД с помощью миграций.

<!-- more -->

Более подробно о том, как пользоваться несколькими БД есть в [документации rails](http://apidock.com/rails/ActiveRecord/Base), ищите по слову
`establish_connection`. Я постараюсь осветить в этой статье то, чего в документации нет.

Во-первых, рельсы умеют загружать и сохранять схемы нескольких БД, делается это следующим образом. Добавляете новую БД в
свой `database.yml`.

{% codeblock database.yml %}
foo_development:
  database: foo
  <<: *defaults

foo_test:
  database: foo_test
  <<: *defaults
{% endcodeblock %}

Создаете rake-задачу `lib/tasks/db.rake`.

{% codeblock lang:ruby lib/tasks/db.rake %}
namespace :db do
  namespace :schema do
    task :dump => [:environment, :load_config] do
      filename = "#{Rails.root}/db/foo_schema.rb"
      File.open(filename, 'w:utf-8') do |file|
        ActiveRecord::Base.establish_connection("foo_#{Rails.env}")
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end

  namespace :test do
    # desc 'Purge and load foo_test schema'
    task :load_schema do
      abcs = ActiveRecord::Base.configurations
      ActiveRecord::Base.connection.recreate_database(abcs['foo_test']['database'])
      ActiveRecord::Base.establish_connection('foo_test')
      ActiveRecord::Schema.verbose = false
      load("#{Rails.root}/db/foo_schema.rb")
    end
  end
end
{% endcodeblock %}

Казалось бы, что все отлично, но после прохождения тестов данные, которые они сгенерировали, удаляются (не знаю, как
более корректно выразить то, что каждый тест выполняется внутри транзакции и в конце каждого теста делается `ROLLBACK`)
только из основной БД. Чтобы поправить это, необходимо завернуть выполнение теста в транзакцию по второй БД, для чего
добавить следующие строки в ваш файл `spec/spec_helper.rb`.

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.around(:each) do |ex|
    main = ActiveRecord::Base.connection
    foo = AnotherDBClass.connection
    main.transaction(:requires_new => true, :joinable => false) do
      foo.transaction(:requires_new => true, :joinable => false, &ex)
    end
  end
end

{% endcodeblock %}

Если в процессе выполнения тестов, вы будете видеть сообщение `WARNING:  there is already a transaction in progress` —
не пугайтесь. С ходу поправить эту ошибку мне не удалось, но, кроме создания визуального неудобства, эта надпись никак не мешает работать.
