---
layout: post
title: Несколько баз данных
date: 2009-05-19 22:52
comments: true
categories: 
- rollback
- rspec
- transaction
---

В некоторых ситуациях необходимо использовать более чем одну базу данных в проекте. Например, статистику и большие
таблицы хранить на другом сервере, у которого большой и медленный диск, а данные, которые нужны постоянно, хранить на
основном сервере с маленьким и быстрым диском.

В нашем случае хотелось унести большие таблицы на другой сервер, чтобы в дисковом кэше (а у главного сервера БД 32 Гб
оперативной памяти) хранились все рабочие таблицы и никогда оттуда не убегали.

Делаем абстракный класс SecondDb, в котором указываем, с каким сервером БД соединяться.

``` ruby
    class SecondDb < ActiveRecord::Base
      self.abstract_class = true
      establish_connection "linkfeed2_#{RAILS_ENV || 'development'}"
    end
```

Наследуем от этого класса тот класс, который будем хранить в другой БД:

``` ruby
    class Message < SecondDb
    end
```


Не забываем, что миграции тоже должны использовать SecondDb:

``` ruby
    SecondDb.connection.create_table :auto_buy_stats do |t|
      t.timestamps
    end
```

Но сразу возникает проблема с тестами. Дело в том, что после теста откатывается (ROLLBACK) только основная БД. Для того,
чтобы и на второй БД транзакции откатывались, можно вот так пропатчить spec/spec_helper.rb (rspec 1.1.1)

``` ruby
    module Test #:nodoc:
      module Unit #:nodoc:
        class TestCase #:nodoc:
          remove_const('DATABASES') if defined?(DATABASES)
          DATABASES = [ActiveRecord::Base, SecondDb]

          def setup_preloaded_fixtures
            return if @fixtures_setup
            @fixtures_setup = true
            return unless defined?(ActiveRecord::Base) && !ActiveRecord::Base.configurations.blank?

            if pre_loaded_fixtures && !use_transactional_fixtures
              raise RuntimeError, 'pre_loaded_fixtures requires use_transactional_fixtures'
            end

            @fixture_cache = {}

            # Load fixtures once and begin transaction.
            if use_transactional_fixtures?
              if @@already_loaded_fixtures[self.class]
                @loaded_fixtures = @@already_loaded_fixtures[self.class]
              else
                load_fixtures
                @@already_loaded_fixtures[self.class] = @loaded_fixtures
              end
              DATABASES.each do |db|
                if db.respond_to?(:increment_open_transactions, true)
                  # rails < 2.2
                  db.send :increment_open_transactions
                else
                  # rails >= 2.2
                  db.connection.send :increment_open_transactions
                end
                db.connection.begin_db_transaction
              end
              # Load fixtures for every test.
            else
              Fixtures.reset_cache
              @@already_loaded_fixtures[self.class] = nil
              load_fixtures
            end

            # Instantiate fixtures for every test if requested.
            instantiate_fixtures if use_instantiated_fixtures
          end

          setup_fixtures_method_name = Test::Unit::TestCase.instance_methods.include?('setup_fixtures') ? :setup_fixtures : :setup_with_fixtures
          alias_method setup_fixtures_method_name, :setup_preloaded_fixtures
          alias_method :setup, setup_fixtures_method_name

          def teardown_preloaded_fixtures
            return if @fixtures_teardown
            @fixtures_teardown = true
            return unless defined?(ActiveRecord::Base) && !ActiveRecord::Base.configurations.blank?

            unless use_transactional_fixtures?
              Fixtures.reset_cache
            end

            # Rollback changes if a transaction is active.
            if use_transactional_fixtures?
              DATABASES.each do |db|
                db.connection.rollback_db_transaction
                if db.respond_to?(:increment_open_transactions, true)
                  # rails < 2.2
                  Thread.current['open_transactions'] = 0
                else
                  # rails >= 2.2
                  db.connection.instance_variable_set('@open_transactions',0)
                end
              end
            end
            ActiveRecord::Base.verify_active_connections!
          end

          teardown_fixtures_method_name = Test::Unit::TestCase.instance_methods.include?('teardown_fixtures') ? :teardown_fixtures : :teardown_with_fixtures
          alias_method teardown_fixtures_method_name, :teardown_preloaded_fixtures
          alias_method :teardown, teardown_fixtures_method_name
        end
      end
    end
```

Вуаля!
