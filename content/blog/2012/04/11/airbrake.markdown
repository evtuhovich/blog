---

title: "Быстрое удаление старых ошибок из airbrake через API"
date: 2012-04-11T21:14:00
comments: true
tags: 
- airbrake
---

Так сложилось, что у нас накопилось достаточно много старых исключений в [airbrake](http://airbrake.io) — сервисе по
сбору и хранению исключений. Ошибки эти не то, чтобы мешали, но
мозолили глаза. И закрыть их руками не представлялось возможным, тем более, что в airbrake это реализовано очень
неудобно — необходимо открыть отдельную страницу с исключением, и там тыкнуть на достаточно неудобный самописный элемент
управления.

Когда такую операцию надо сделать несколько сотен раз, автоматически опускаются руки. Но оказалось, что у airbrake есть
API, которым можно достаточно успешно пользоваться. [Документирован он
никак](http://help.airbrake.io/kb/api-2/api-overview), но можно догадаться о некоторых адресах по
адресам в основном приложении.

Ниже привожу код на ruby, который вытаскивает список ошибок через API и закрывает их. Я отформатировал их для красоты,
в реальности я запускал однострочные команды, чтобы удобнее было их повторять в irb.

```ruby
require 'rubygems'
require 'nokogiri'
require 'rest-client'

auth_token = "your_token" # взять на страничке "My Settings" 
                          # https://your_account.airbrake.io/users/your_id/edit

project_id = 123456       # взять из урла в airbrake, иначе выводится 
                          # список ошибок из всех проектов

ids = (4..8).to_a.map { |page|
  Nokogiri::XML(RestClient.get "https://your_account.airbrake.io/errors.xml" +
      "?auth_token=#{auth_token}&page=#{page}&project_id=#{project_id}").
    search('group/id').map(&:text) 
}.flatten

ids.each { |id|
  # чтобы не ждать, пока дофига запросов выполнится последовательно
  Thread.new { 
    RestClient.put("https://your_account.airbrake.io/errors/#{id}?auth_token=#{auth_token}",
      :group => {:resolved => true}) 
  } 
}
```
