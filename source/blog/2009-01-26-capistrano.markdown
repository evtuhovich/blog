---
layout: post
title: Использование capistrano
date: 2009-01-26 10:32:00 UTC
comments: true
published: true
categories:
- deploy
- capistrano
---

Для выкатки (deploy) я не знаю другого инструмента, кроме capistrano. Слышал про vlad, но в глаза его никогда не
видел.

Использовать capistrano имеет смысл при любом размере проекта, будь то сайт из 3-5 страничек, или что-то большое. Во
втором случае отказ от использования capistrano — форменное безумие с моей точки зрения.

Начать знакомиться лучше всего [отсюда](https://github.com/capistrano/capistrano/wiki/).

Если вкратце, то заходим в каталог проекта и набираем:

{% codeblock %}
    capify .
{% endcodeblock %}

Дальше правим файл `config/deploy.rb`, в нем все более или менее понятно.

Несколько тонкостей.

``` ruby
    set :deploy_via, :remote_cache # чтобы каждый раз не тянуть весь проект из системы
                                   # контроля версий, что иногда происходит не очень быстро.
                                   # В документации есть и другие варианты, стоит прочесть.

    set :copy_exclude, [".git"]    # это достаточно заметно ускоряет процесс копирования
                                   # кода из кеша в текущую выкатку

```

Иногда не надо выкатывать на все сервера, а хочется выкатить только на несколько конкретных

```
    cap HOSTS=w1.mydomain.ru deploy
```

Есть еще вариант с HOSTFILTER,
[подробности в рассылке capistrano](http://groups.google.co.uk/group/capistrano/browse_thread/thread/0592ab63dda72d7e?hl=en#)

Если есть необходимость в нескольких конфигурациях для выкатки одного и того же приложения (а разве бывает по-другому?),
то для этого подходить плагин multistage. Для этого надо
{% codeblock %}
gem install capistrano-ext
{% endcodeblock %}
В файле `config/deploy.rb` добавить:

``` ruby
    set :stages, %w(production staging)
    require 'capistrano/ext/multistage'
```

В файлах `config/deploy/staging.rb` и `config/deploy/production.rb` описать, как выкатывать в разные места. Лучше всего
держать всю логику выкатки в `config/deploy.rb`, а в `staging.rb` и `production.rb` только описание, какую ветку и на
какие сервера выкатывать. И в крайнем случае какую-то специфичную логику. Это поможет избежать казусов, когда на staging у
вас выкатывается все хорошо, а с выкаткой на production возникают проблемы.

{% codeblock conifg/deploy/staging.rb %}
role :app,    "beta.mysite.ru", :sphinx => true
role :web,    "beta.mysite.ru"
role :static, "beta.mysite.ru"
role :db,     "beta.mysite.ru", :primary => true

set :branch, "new_feature"

# здесь тот самый случай, когда мы не запускаем DelayedJob на staging,
# чтобы он письма не разослал кому не надо
namespace :deploy do
  desc "Restart delayed job"
  task :restart_dj, :roles => :app do
    run "echo No delayed_job on staging"
  end
end

{% endcodeblock %}

Далее

```
    cap staging deploy
```

После того, как все проверили на staging

```
    cap production deploy
```

Очень хорошо, подробно и по-русски написано про выкатку с помощью capistrano
[в блоге у моего бывшего коллеги Максима Добрякова](http://maksd.info/tag/capistrano).
