---
layout: post
title: Слияние HashWithIndifferentAccess с обычными хешами
date: 2011-09-09 23:16
comments: true
tags:
- HashWithIndifferentAccess
---

Сегодня у нас перестали ходить отчеты по почте. Ходили, ходили и вдруг перестали. Kлассы выглядели следующим образом
(ненужные подробности я опустил).

``` ruby
    class ReportSender
      def initialize(report_instance)
        @report_instance = report_instance
        @params = report_instance.params
        @emails =  @params.delete(:mail_to)
      end
```

``` ruby
    class Report
      def initialize(params = {})
        @params = self.class.default_values.merge(params)
      end
```

К классам отчетов были добавлены значения по-умолчанию, и, как оказалось, из-за них были все проблемы.

Хеш `params`, которые передается в класс `Report` — это тот самый `params` из контроллера. У него базовый класс — `HashWithIndifferentAccess`.

А теперь посмотрим на такой пример:

``` ruby
    {"a" => 1}.merge( HashWithIndifferentAccess.new "b" => 1 )[:b]
    # => nil 
    HashWithIndifferentAccess.new("a" => 1).merge("b" => 1)[:b]
    # => 1 
```

То есть, если `Hash` слить с `HashWithIndifferentAccess`, nо получится `Hash`. И обращение по ключу `:mail_to`
возвращало `nil`, потому что ключ был `"mail_to"`.

Надеюсь, это поможет кому-то сэкономить те 45 минут, которые я потратил сегодня вечером, разбираясь с этой проблемой.
