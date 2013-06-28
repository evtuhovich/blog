---
layout: post
title: Проблемы с find_in_batches
date: 2011-09-11 00:22
comments: true
categories:
- rails
- ActiveRecord
---

Иногда мне кажется, что большинство инженерных историй похожи как две капли воды. Вот и эта история началась с того, что 
в одном большом отчете цифры не сходились раза в два.

Мысленно закурив трубку, как Шерлок Холмс, я взялся за дело. Вот таким образом выглядела модель, по которой считались
цифры (я опускаю ненужные подробности).

``` ruby
    class OfferDescription < ActiveRecord::Base
      has_many :children, :class_name => 'OfferDescription', :foreign_key => :parent_id
    end
```

В отчете данные группировались по родительским объектам `OfferDescription`.
Именно у объектов, у которых были дети, в отчетах были все нули. Рассчитывал
отчеты приблизительно вот такой код.

``` ruby
    OfferDescription.scoped(:conditions => {:parent_id => nil}).find_in_batches do |batch|
      batch.each do |offer_description|
        if offer_description.children.present?
          # здесь считаем цифры по детям
        else
          # здесь просто считаем цифры
        end
      end
    end
```

Если бы я сразу прочитал первый комментарий на 
[apidock.com для find_in_batches](http://apidock.com/rails/ActiveRecord/Batches/ClassMethods/find_in_batches#771-Careful-with-scopes),
то сэкономил бы себе изрядное количество времени, но кто читает документацию,
а тем более комментарии к ней?

Дело в том, что `find_in_batches` накладывает свои условия на все обращения к
модели, из которой он вызван, внутри блока, который ему передан. То есть, в
нашем примере, `children.present?` всегда будет возвращать `false`, потому что
в выборку детей всегда будет добавляться условие `:parent_id => nil`.

Более того, следующий код тоже не будет работать (в примере взяты id, которые
существуют в базе данных), потому что условия в запросе к БД никогда не выполняются.

``` ruby
    OfferDescription.scoped(:conditions => {:id => 16005}).find_in_batches do |batch|
      batch.each do |offer_description|
        OfferDescription.find 18847
        # здесь запрос к базе данных будет вот таким
        # SELECT * FROM "offer_descriptions" WHERE 
        # ("offer_descriptions"."id" = 18847) AND ("offer_descriptions"."id" = 16005)
      end
    end
```

Говоря откровенно, я не понимаю, зачем так сделано. Если кто-то объяснит мне
тайный смысл этого в комментариях, я буду ему очень благодарен.

Все вышесказанное не умаляет полезности самого метода `find_in_batches`,
потому что запросы к базе данных, которые он генерируют, позволяют выбрать все
данные из базы, во многих случаях не создавая большую нагрузку. И конечно, он
работает всегда не медленнее, чем постраничный перебор с использованием
`:limit` и `:offset`.
