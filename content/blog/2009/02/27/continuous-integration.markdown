---

title: Непрерывная интеграция
date: 2009-02-27T14:45:00
comments: true
tags:
- cruisecontrol
- continuous integration
---

О непрерывной интеграции (Continuous Integration) можно почитать у Мартина Фаулера (Martin Fowler) <a
href="http://martinfowler.com/articles/continuousIntegration.html">здесь</a>. В друх словах, это практика постоянной
интеграции наработок каждого программиста. Обычно это заключается в том, что на какой-нибудь машине постоянно (после
каждого изменения в исходных кодах) собирается проект и прогоняются все тесты. Результаты этих действий высылаются
разработчикам по почте. Это позволяет постоянно сохранять проект в относительно рабочем состоянии.

Удобным инструментом непрерывной интеграции является <a
href="http://cruisecontrolrb.thoughtworks.com">CruiseControl</a>. К сожалению в своей оригинальной версии он
поддерживает только систему контроля версий svn. Поддержку git дописали народные умельцы. Я воспользовался вот <a
href="http://github.com/p8/cruisecontrolrb/tree/master">этой веткой</a>.

Теперь каждый день по несколько раз мы получаем такие письма:

```
    The build failed.

    CHANGES
    -------
    Build was manually requested


    See http://cruise.ourdomain.com/builds/linkfeed/98bb78b.1 for details.
```

Все тесты выполняются у нас 5-6 минут, поэтому каждый раз прогонять все на своей машине достаточно утомительно.
CruiseControl позволяет сохранять проект в более "целостном" состоянии.

В дальнейшем я планирую прикрутить к нему проверку покрытия тестами (Test Coverage) с помощью rcov.
