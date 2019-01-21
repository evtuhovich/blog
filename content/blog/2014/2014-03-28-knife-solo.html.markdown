---
title: Соло на ноже
date: 2014-03-28T18:11:00
tags:
- knife
- chef
---

Очень часто для небольших проектов нет необходимости усложнять инфраструктуру с использованием chef-server. Существует
мнение, что chef server, вообще, не нужен, и многие аргументы в пользу этой идеи кажутся мне вполне убедительными.

Для людей, которым нравится DSL chef и не нужен chef server, есть [chef-solo](http://docs.opscode.com/chef_solo.html).
Чтобы готовить с его помощью, нужен специальный нож — [knife-solo](http://matschaffer.github.io/knife-solo/). Это
инструмент, который значительно упрощает использование chef-solo.

Для начала поставить knife-solo

```
gem install knife-solo
```

Если у вас есть уже готовый репозитарий для chef, как, например, наше [тесто](https://github.com/express42-cookbooks/testo),
то следующий шаг можно пропустить. В противном случае сделайте начальный репозитарий.

```
knife solo init .
```

Далее вы подготавливаете ноду (сервер) для работы с knife-solo

```
knife solo prepare ubuntu@myhostname --bootstrap-version 11.10.04
```

Последний параметр нужен из-за досадного бага в chef 11.10.0 (а именно он ставится по умолчанию при выполнении команды
`prepare`), из-за которого chef-solo толком не работал, а я потратил 2 часа своей жизни.

После выполнения этой команды в папке `nodes` появится файл `myhostname.json` со следующим содержанием:

```json
{
  "run_list": [
  ]
}
```

Давайте поправим этот файл, добавив ноде какие-нибудь роли или рецепты.

```json
{
  "run_list": [
    "role[base]"
  ]
}
```


После этого можно запустить команду `cook`. Она синхронизирует текущую папку на удаленную ноду, после чего запустит на
удаленной ноде chef-solo.

```
$ knife solo cook myhostname
WARNING: No knife configuration file found
Running Chef on myhostname...
Checking Chef version...
Installing Librarian cookbooks...
Uploading the kitchen...
Generating solo config...
Running Chef...
Starting Chef Client, version 11.10.4
Compiling Cookbooks...
[2014-03-28T08:08:28+00:00] WARN: ssh_known_hosts requires Chef search - Chef Solo does not support search!
Recipe: base::default
  * chef_gem[pony] action install (up to date)
[2014-03-28T08:08:28+00:00] WARN: Cloning resource attributes for package[sudo] from prior resource (CHEF-3694)
[2014-03-28T08:08:28+00:00] WARN: Previous package[sudo]: /home/brun/chef-solo/cookbooks-2/base/recipes/default.rb:69:in `block in from_file'
[2014-03-28T08:08:28+00:00] WARN: Current  package[sudo]: /home/brun/chef-solo/cookbooks-2/sudo/recipes/default.rb:20:in `from_file'
[2014-03-28T08:08:28+00:00] WARN: Cloning resource attributes for package[git-core] from prior resource (CHEF-3694)
[2014-03-28T08:08:28+00:00] WARN: Previous package[git-core]: /home/brun/chef-solo/cookbooks-2/ruby/recipes/ruby_build.rb:35:in `block in from_file'
[2014-03-28T08:08:28+00:00] WARN: Current  package[git-core]: /home/brun/chef-solo/cookbooks-2/ruby/recipes/chruby.rb:35:in `block in from_file'
Converging 108 resources
...
```

Очень здорово, что knife-solo интегрирован с librarian/berkshelf, и для того, чтобы вносить изменения, вам надо просто
поправить рецепт и еще раз вызвать `knife solo cook myhostname`. Стоит отметить, что первый раз синхронизация может
выполняться достаточно долго, но потом переносятся только изменения, что происходит очень быстро.

Если вы хотите быстро начать пользоваться шефом, не вникая во всю сложную кухню работы с chef-server, авторизации на нем
и всяком таком, то я рекомендую попробовать knife-solo.

Кстати, для тех, кто не в курсе (то есть для всех), у нашей компании «Экспресс 42» есть
[технический блог](http://express42.com/techblog.html). Там будут периодически публиковаться статься, посвященные управлению
конфигурацией и DevOps, так что подписывайтесь, если вы интересуетесь этой темой.
