---
title: Атрибуты в шефе и DeepMerge
date: 2014-02-14 18:38 MSK
tags:
- chef
---

Многие знают, что в шефе есть большое количество типов атрибутов, необходимые, чтобы гибко управлять инфраструктурой.
Для того, чтобы эти атрибуты работали вместе, есть разные правила их объединения. О них мы сегодня и поговорим.

READMORE

В шефе есть [15 типов атрибутов](http://docs.opscode.com/chef_overview_attributes.html#attribute-precedence), и
если вы будете использовать их все, у вас взорвется мозг. При использовании нашего подхода к использованию шефа (об этом
я рассказывал на последнем [DevOps митапе](http://www.meetup.com/DevOps-Moscow-in-Russian/), который прошел в Яндексе,
видео моего доклада можно [посмотреть здесь](http://tech.yandex.ru/events/yagosti/devops/talks/1597/)), нам, за редким
исключением, удается обойтись всего тремя типами:

* A default attribute located in a cookbook attribute file (1)
* A default attribute located in an environment (3)
* A default attribute located in role (4)

Это позволяет хранить все атрибуты в git. Для примера можно посмотреть наш
[тестовый репозиторий тесто](https://github.com/express42-cookbooks/testo).

Следующий момент, на который стоит обратить внимание при работе с атрибутами, — это «глубокое слияние» или deep merge
в английском варианте. Поставим небольшой эксперимент с помощью `chef-shell` (это такой irb с загруженными классами шеф
клиента).

```
➜  chef-shell
loading configuration: none (standalone session)
Session type: standalone
Loading....done.

This is the chef-shell.
 Chef Version: 11.10.0
 http://www.opscode.com/chef
 http://docs.opscode.com/

run `help' for help, `exit' or ^D to quit.

Ohai2u brun@Ivans-MacBook-Pro.local!
chef > dm = Chef::Mixin::DeepMerge
 => Chef::Mixin::DeepMerge
chef > a = { :x => [1, 2] }
 => {:x=>[1, 2]}
chef > b = { :x => [3] }
 => {:x=>[3]}
chef > dm.merge a, b
 => {"x"=>[1, 2, 3]}
```

Или в сухом остатке

```ruby
dm = Chef::Mixin::DeepMerge
a = { :x => [1, 2] }
b = { :x => [3] }
dm.merge a, b
# => {"x"=>[1, 2, 3]}
```

Если значениями являются массивы, то они объединяются. Возможно, иногда это очень полезно, но про эту особенность надо
помнить, чтобы не случилось ситуации, о которой я сейчас расскажу.

В файле атрибутов были заданы приватные сети следующим образом:

```ruby
# inhouse-cookbooks/base/attributes/default.rb

default['base']['private_networks'] = ["192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
```

Боевая среда находилась в облаке Rackspace. У них сеть 10.0.0.0/8 является внутренней сетью, в которую «торчат»
различные сервисы, в том числе Load Balancer. Поэтому в атрибутах боевого окружения было прописано следующее (`environments/production.json`):

```json
{
  "name": "production",
  "description": "Produciton environment",
  "cookbook_versions": {
  },
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "default_attributes": {
    "base": {
      "private_networks": ["192.168.0.0/16", "172.16.0.0/12"]
    }
  }
}
```

В результате deep merge публичных ip адресов на сервисе не стало.

Я решил эту проблему по-простому, стал хранить список в одной строке с разделителем-запятой, потому что строки при deep
merge заменяются.

```ruby
default['base']['private_networks'] = "192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"
```

Подробности про deep merge можно прочитать в [официальной документации](http://docs.opscode.com/essentials_node_object_deep_merge.html).

Стоит также обратить внимание, что атрибуты из файлов атрибутов загружаются в алфавитном порядке. Например, совсем
недавно, наткнулся на ошибку, связанную с этим (и, более того, чуть раньше на нее наткнулся мой коллега Никита на другом
проекте).

```
$ ls inhouse-cookbooks/project/attributes
front.rb
riemann.rb
```

```ruby
# inhouse-cookbooks/project/attributes/front.rb

default['project']['front']['application_user'] = 'project'

# inhouse-cookbooks/project/attributes/riemann.rb

default['project']['riemann']['application_directory'] =
    "/home/#{node['project']['front']['application_user']}/riemann"

default['project']['riemann-dash']['application_directory'] =
    "/home/#{node['project']['front']['application_user']}/riemann-dash"
```

В какой-то момент я переименовал рецепт front в ruby, и все сломалось, потому что ruby идет после riemann в алфавитной
сортировке.

И третий момент, на который стоит обратить внимание, это то, что атрибуты одного типа (с одинаковым приоритетом) не
объединяются, а перетирают друг друга. Вот вам умозрительный пример (спасибо Никите, который наткнулся на это в реальной
жизни и рассказал мне).

```ruby
# inhouse-cookbooks/project/attributes/app_one.rb

default['logrotate']['log_files'] = ['/var/log/app_one.log']

# inhouse-cookbooks/project/attributes/app_two.rb

default['logrotate']['log_files'] = ['/var/log/app_two.log']
```

Казалось бы, очевидный способ собрать массив из разных элементов, но конструктивные особенности шефа сделают так, что
нужный нам атрибут будет содержать массив с одним элементом `'/var/log/app_two.log'` — последним.

Если бы спросили меня про атрибуты в шефе, я бы сказал, что они сделаны, гм, весьма странно, что ли, в них не хватает инженерной
красоты.

Надеюсь, эта статья убережет вас от хождения по совсем неинтересным граблям.
