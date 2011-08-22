---           
layout: post
title: Проблемы с кэшированием
date: 2009-03-22 13:18:00 UTC
comments: false
categories: кэш кэширование memcache rails
published: false
---

Все ситуации, о которых я здесь пишу, встретились мне в повседневной работе. Единственное, что меняю название классов, чтобы не утруждать моего читателя незнакомой для него предметной областью.

Итак, у нас есть следующие модели:

{% codeblock shop.rb %}
class Shop < ActiveRecord::Base
  has_many :categories

  cached_methods do
    def wait_orders_count
      Order.count :conditions =&gt; {:status_id =&gt; Order::WAIT}
    end

    def paid_orders_count
      Order.count :conditions =&gt; {:status_id =&gt; Order::PAID}
    end

    def bad_orders_count
      Order.count :conditions =&gt; {:status_id =&gt; Order::BAD}
    end
  end
end
{% endcodeblock %}

<span class="keyword">class </span><span class="class">Category</span> <span class="punct">&lt;</span> <span class="constant">ActiveRecord</span><span class="punct">::</span><span class="constant">Base</span>
  <span class="ident">belongs_to</span> <span class="symbol">:shop</span>
  <span class="ident">has_many</span> <span class="symbol">:products</span>
<span class="keyword">end</span>

<span class="keyword">class </span><span class="class">Product</span> <span class="punct">&lt;</span> <span class="constant">ActiveRecord</span><span class="punct">::</span><span class="constant">Base</span>
  <span class="ident">belongs_to</span> <span class="symbol">:category</span>
  <span class="ident">has_many</span> <span class="symbol">:orders</span>
<span class="keyword">end</span>

<span class="keyword">class </span><span class="class">Order</span>
  <span class="ident">belongs_to</span> <span class="symbol">:product</span>
<span class="keyword">end</span>
</pre>

Методы внутри cached_methods выполняются в том случае, если значение для них не нашлось в кэше (например, в memcached). До этого поля *_orders_count хранились в базе и мы добавляли к ним +1/-1 каждый раз, когда изменяли статус заказа (Order). Если магазин большой, то таких обновлений будет очень много, что создает нагрузку на базу, поэтому их и вынесли в кэш. Чтобы не думать, каждый раз при обновлении статуса заказа, мы сбрасывали кэши для конкретного магазина.

С такой логикой мы выкатились на живой сервер. И база легла под наплывом запросов вида <code>SELECT COUNT(*) FROM orders WHERE status_id = ?</code>. В срочном порядке пришлось откатываться, и несколько дней работы на смарку (кэшей в реальности было больше и были они в разных моделях).

Мне видится 2 способа решения этой проблемы:<ol>
<li>Сбрасывать кэш только по истечении какого-то времени, то есть, фактически, пересчитывать его раз в какой-то интервал
</li>
<li>Инкрементально обновлять кэш
</li></ol>
Первый способ гораздо проще в реализации. Если особая точность данных не нужна, то он вполне подходит.

Второй способ позволяет всегда иметь актуальные счетчики (если нигде нет ошибки). 

Бизнес-требования вынудили нас идти по второму пути.<div class="blogger-post-footer"><img width='1' height='1' src='https://blogger.googleusercontent.com/tracker/12147316-3727314390277993720?l=evtuhovich.blogspot.com' alt='' /></div>
