---
layout: post
title: Проблемы с кэшированием
date: 2009-03-22 13:18:00 UTC
comments: true
categories: кэш кэширование memcache rails
published: true
---

Все ситуации, о которых я здесь пишу, встретились мне в повседневной работе. Единственное, что я делаю — меняю название классов,
чтобы не утруждать моего читателя незнакомой для него предметной областью.

Итак, у нас есть следующие модели:

{% codeblock shop.rb %}
class Shop < ActiveRecord::Base
  has_many :categories

  cached_methods do
    def wait_orders_count
      Order.count :conditions => {:status_id => Order::WAIT}
    end

    def paid_orders_count
      Order.count :conditions => {:status_id => Order::PAID}
    end

    def bad_orders_count
      Order.count :conditions => {:status_id => Order::BAD}
    end
  end
end

class Category < ActiveRecord::Base
  belongs_to :shop
  has_many :products
end

class Product < ActiveRecord::Base
  belongs_to :category
  has_many :orders
end

class Order
  belongs_to :product
end

{% endcodeblock %}

Методы внутри `cached_methods` выполняются в том случае, если значение для них не нашлось в кэше (например, в memcached).
До этого поля *_orders_count хранились в базе и мы добавляли к ним +1/-1 каждый раз, когда изменяли статус заказа
(Order). Если магазин большой, то таких обновлений будет очень много, что создает нагрузку на базу, поэтому их и вынесли
в кэш. Чтобы не думать, каждый раз при обновлении статуса заказа, мы полностью сбрасывали кэши для конкретного магазина.

С такой логикой мы выкатились на живой сервер. И база легла под наплывом запросов вида `SELECT COUNT(*) FROM orders
WHERE status_id = ?`. В срочном порядке пришлось откатываться, и несколько дней работы на смарку (кэшей в
реальности было больше и были они в разных моделях).

Мне видится 2 способа решения этой проблемы:

* сбрасывать кэш только по истечении какого-то времени, то есть, фактически, пересчитывать его раз в какой-то интервал;
* инкрементально обновлять кэш.

Первый способ гораздо проще в реализации. Если особая точность данных не нужна, то он вполне подходит.

Второй способ позволяет всегда иметь актуальные счетчики (если нигде нет ошибки).

Бизнес-требования вынудили нас идти по второму пути.
