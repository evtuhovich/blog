---

title: Использование ruby-debug
date: 2009-07-30T22:22:00
comments: true
tags: 
- ruby-debug
---

Использование дебаггера при разработке — это плохой тон. Это значит, что вы не понимаете, как работает ваша программа.
Но иногда жизнь без дебаггера становится невыносимой.

Есть отличный плагин vim-ruby-debugger для редактора vim. Но он пока сыроват и не все возможности в нем есть. По крайней
мере в моем случае, чтобы понять, что происходить внутри спека, он не помог.

Тогда я воспользовался старым дедовским способом:

``` ruby
    require 'ruby-debug'
    Debugger.start
```

И вставил вызов debugger в том месте, где мне это необходимо.

Когда дебаггер дойдет до нужного места, появится консоль дебаггера.

```
    (rdb:1) help
    ruby-debug help v0.10.3
    Type 'help ' for help on a specific command

    Available commands:
    backtrace  catch      continue  disable    down    enable   exit     frame  info   
    list       next       pp        putl       reload  save     show     step   trace  
    up         where      break     condition  delete  display  edit     eval   finish 
    help       irb        method    p          ps      quit     restart  set    source 
    thread     undisplay  var      
```

Остальное можно понять, набрав `help command-name`.

*PS* В моем случае мне пришлось посмотреть значение двух переменных, чтобы понять, где вкралась ошибка. И сразу 100 тестов
починились исправлением одной строки. Впереди еще чуть меньше 500.

