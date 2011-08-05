---
layout: post
title: Проблема с проверкой уникальности какого-то поля в rails
date: 2009-05-28 22:22
comments: true
categories: 
- rails
- validates_uniqueness_of
- индексы
---
Пусть в модели User у нас описана валидация для поля email

``` ruby
    validates_uniqueness_of :email, :case_sensitive => false, 
      :message => i18n_proxy(:email_already_registered)
```

Следующий код генерирует вот такой запрос к базе данных:

``` sql
    SELECT * FROM users WHERE lower(email) = 'thmth' LIMIT 1
```

А на таблице users у нас индекс по полю email. В postgresql запрос, что вверху,
не будет использовать индекс. Представьте, что будет, когда в таблице users
десятки тысяч записей, а на каждое изменение любого поля в users вызывается
такой запрос.

Именно это я наблюдал совсем недавно на нашей живой базе. Проблема решается
просто, например, убрать `:case_sensetive`, а email всегда
предварительно переводить в нижние буквы.

Есть другой вариант, сделать функциональный индекс:

``` sql
    CREATE INDEX ON users(lower(email))
```

Беда в том, что в таком случае (а его мы тоже используем, но уже в другом проекте) придется держать 2 индекса на email - 
обычный и функциональный. И вот почему:

``` ruby
    User.find_by_email 'evtuhovich@gmail.com'
```

Этот код выполнит в БД следующий запрос:

``` sql
    SELECT * FROM "users" WHERE ("users"."email" = 'evtuhovich@gmail.com') LIMIT 1
```

В любом случае, все зависит от решаемой задачи.
