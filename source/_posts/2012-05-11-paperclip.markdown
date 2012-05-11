---
layout: post
title: Странное поведение создателей Paperclip
date: 2012-05-11 23:23
comments: true
categories:
- paperclip
---

Вчера я разворачивал наше приложение в системе CI [Jenkins](http://jenkins-ci.org/), и обнаружил, что bundler не находит
gem paperclip. В Gemfile была явно прописана версия 3.0.1. Зайдя на [rubygems](https://rubygems.org/gems/paperclip/versions), я увидел,
что эту версию гема его создатели удалили, а версия 3.0.2 и старше не поставилась, выругавшись на то, что ей нужен ruby
1.9.2 и старше.

<!-- more -->

Компания [Thoughtbot](http://thoughtbot.com/) и раньше была замечена в фашизме, выпилив внезапно поддержку подтверждения
email из своего гема [Clearance](https://rubygems.org/gems/clearance) в одной из версий, после чего он потерял обратную
совместимость. Данная же ситуация просто не укладывается у меня в голове. Причем я не понимаю, зачем было удалять старый
gem с rubygems, насильно заставляя всех в один день обновиться на ruby 1.9, что, надо сказать, задача никак ни одного
дня.

Проблема решилась добавлением следующего кода в `Gemfile`:

{% codeblock lang:ruby %}
gem 'paperclip',  '3.0.1',
                  :git => 'git://github.com/thoughtbot/paperclip.git',
                  :tag => 'v3.0.1'
{% endcodeblock %}

Если вы поддерживаете какие-то gem-ы, никогда не поступайте так плохо, как это сделали Thoughtbot.
