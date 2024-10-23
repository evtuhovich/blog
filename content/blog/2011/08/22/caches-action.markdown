---

title: "Некоторые проблемы с cached_action в Rails 2.3"
date: 2011-08-22T13:02:00
comments: true
tags:
- rails
- caches_action
---

На Групоне у нас есть внутренняя страница, на которой динамически отображаются данные о продажах по различным городам.
Результаты этой страницы зависят от параметров, которые передаются в метод show. А потом эта страница динамически
обновляется с помощью ajax-запросов.

```
# dashboard.rb
class Admin::DashboardsController < Admin::BaseController
  layout "admin"

  def show
    # Здесь сложные-сложные запросы к БД

    if request.xhr?
      render 'show', :layout => false
    end
  end
end
```

Поскольку запросы очень тяжелые, да и сама страничка непростая, то отдача ее сильно нагружала БД и app-сервера.

В какой-то момент мы решили ее закешировать. Казалось бы, чего уж проще (отмечу, что мы используем Rails 2.3.14).

```
# dashboard.rb
class Admin::DashboardsController < Admin::BaseController
  caches_action :show, :expires_in => 3.minutes
```

Но не тут-то было, потому что `caches_action` по-умолчанию не обращает внимание на передаваемые параметры. Вникнув в
[документацию](http://apidock.com/rails/ActionController/Caching/Actions), я переделал на следующий вариант.

```
# dashboard.rb
class Admin::DashboardsController < Admin::BaseController
  caches_action :show, :expires_in => 3.minutes,
    :layout => false,
    :cache_path => Proc.new { |c| c.params }
```

Во-первых, `:layout => false` говорит, что не надо кешировать layout. В
админке у разных пользователей разные заголовки и отображаемые вкладки, в
зависимости от прав, поэтому не надо, чтобы они попадали в кеш.

Во-вторых, `:caches_path` отвечает за генерацию ключа для кеширования. Вот с ним-то и возникла проблема, потому что этот ключ
для обычных и ajax запросов будет один и тот же. Более того, в коде `show.html.haml` оказался проблемный кусок.

```
# show.html.haml
- content_for :head do
  = include_stylesheets :admin_dashboard
```

Из-за него на странице перестали подхватываться стили, и из кеша эта страница доставалась уже «битая». Я убрал `content_for`,
что, конечно, не очень изящно, но для админки простительно. Код же я переписал следующим образом.

```
# dashboard.rb
class Admin::DashboardsController < Admin::BaseController
  caches_action :show, :expires_in => 3.minutes,
    :layout => false,
    :cache_path => Proc.new { |c| c.params.merge!("xhr" => c.request.xhr?.to_s) }
```

Но на этом беды не кончились — по неведомой причине после этого ajax запросы перестали попадать в кеш. Я посоветовался
со своим коллегой [Равилем](https://github.com/brainopia), который подсказал мне, 
[куда смотреть](http://railsforum.com/viewtopic.php?id=41906). Оказывается, у `caches_action` есть особенность, что он
кеширует ajax запросы только с `:layout => true`. В итоге у меня получился следующий код.

```
# dashboard.rb
class Admin::DashboardsController < Admin::BaseController
  caches_action :show, :expires_in => 3.minutes,
    :layout => Proc.new { |c| c.request.xhr? },
    :cache_path => Proc.new { |c| c.params.merge!("xhr" => c.request.xhr?.to_s) }
```

Итак, я за одно утро наступил сразу на все возможные грабли с этим методом. Если хоть один человек избежит этого, значит
я написал это не зря.
