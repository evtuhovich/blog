---

title: Переопределение Rails.logger и проблемы с ним 
date: 2010-07-27 22:52
comments: true
tags: 
- rails
---
Часто один и тот же rails-проект используется и для web-части, и для каких-то других задач, выполняемых по расписанию
или для создания демонов. В таких случаях иногда хочется, чтобы логи разных частей писались в разные файлы.

Готового способа для этого я не нашел. Например, посмотрим на такой пример:

```
    $ ./script/console 
    Loading development environment (Rails 2.3.5)

    >>  ActiveRecord::Base.logger = Logger.new(STDOUT)
    => #&lt;Logger:0xb192594 @progname=nil, @level=0, @default_formatter=#&lt;Logger::Formatter:0xb19255c @datetime_format=nil>, formatternil, logdev#&lt;Logger::LogDevice:0xb19247c @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#&lt;IO:&lt;STDOUT>, mutex#&lt;Logger::LogDevice::LogDeviceMutex:0xb192444 @mon_owner=nil, @mon_count=0, @mon_mutex=#&lt;Mutex:0xb19240c>

    >> User.first
    => #&lt;User id: 1, email: "seeduser@scalaxy.ru" ...>
    >> 
```

И где же логи, спросите вы?

Заглянем в исходники рельс (я их слегка урезал здесь для ясности):

``` ruby
    module ConnectionAdapters
      class AbstractAdapter
        def initialize(connection, logger = nil) #:nodoc:
          @connection, @logger = connection, logger
```

Из этого кода понятно, что логгер потерялся в дебрях connection. Исправить ситуацию помогает следующая конструкция:

``` ruby
    ActiveRecord::Base.connection.instance_variable_set('@logger', Logger.new(STDOUT))
```

После этого в консоли:

```
    >> User.first
      User Load (0.1ms)   SELECT * FROM `users` LIMIT 1
    => #&lt;User id: 1, email: "seeduser@scalaxy.ru">
```

Эта проблема отняла у меня изрядное количество времени, надеюсь вам она поможет его сэкономить.
