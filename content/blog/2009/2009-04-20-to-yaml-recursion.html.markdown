---

title: Рекурсивные особенности to_yaml
date: 2009-04-20T13:14:00
comments: true
published: true
tags:
  - yaml
---

Если необходимо сериализовать/десериализовать какой-то объект, то yaml формат хорошо для этого подходит.

В моем проекте мы записывали объекты в очередь, использую yaml-сериализацию. На тестах все было хорошо. Но на живом эта
самая сериализация стала выполняться очень долго.

Оказалось, что если у объекта есть связные объекты, то он их тоже засовывает в yaml, а если таких объектов очень много,
то это будет сложная операция. Понятно, что в примитивных тестах этого было не видно, а подумать хорошо головой в тот
раз не получилось.

```
# test.rb
  u = User.find 1
  print u.to_yaml
  u.projects
  print u.to_yaml
```

```
# result.yml

--- !ruby/object:User
attributes:
  login: user1
attributes_cache: {}

--- !ruby/object:User
attributes:
  login: user1
attributes_cache: {}

projects:
- !ruby/object:Project
  attributes:
    cost_update_date: "2008-01-14"
    max_error_wait: "7"
    name: test2
    created_at: 2009-04-23 12:45:23+04
  attributes_cache: {}

- !ruby/object:Project
  attributes:
    cost_update_date: "2008-01-14"
    max_error_wait: "7"
    name: test
    created_at: 2009-04-23 12:45:23+04
  attributes_cache: {}
```

Решена была эта проблема просто: `object.attributes.to_yaml`.

Это такой забавный баг, что мне хочется выразить его в танце.
