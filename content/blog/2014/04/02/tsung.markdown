---
title: Tsung — цунами ручного приготовления
date: 2014-04-02T18:43:00
tags:
---

С моей точки зрения, любое нагрузочное тестирование — это измерение сферического коня в вакуму в идеальных попугаях. Но
иногда нужны хоть какие-то данные о том, какую нагрузку выдержит ваша система. И тогда на помощь приходят специальные
инструменты для создания нагрузки.

Хороший обзор таких инструментов (httperf, siege, ab, pronk) есть у [Льва Валкина](http://lionet.livejournal.com/99984.html).
Но у нас была задача чуть посложнее, хотелось проверить, как поведет себя система под «реальной» нагрузкой. И если вам
нужны сложные сценарии нагрузки, то тут не обойтись без [tsung](http://tsung.erlang-projects.org/). Хочется сразу
предупредить, что документация, хоть и содержит ответы на многие вопросы, но не блещет особой понятностью и полнотой.
Тем не менее, аналогов этому инструменту я не знаю.

Сейчас мы будем нагрузочно тестировать мой блог (давайте на секунду вообразим, что он стал мегапопулярным). Оставайтесь
с нами, но бойтесь, впереди много xml!

<!--more-->

Для того, чтобы сгенерировать тестовые планы, можно воспользоваться утилитой `tsung-recorder`. После того, как вы
делаете `tsung-recorder start`, на порту 8090 подымается http-прокси. В настройках системы (или браузера) пропишите
прокси localhost:8090 и дальше притворитесь пользователем и прощелкайте сайт. После того, как вам надоест это, выполните
`tsung-recorder stop`, и у вас появится файл вида `/Users/brun/.tsung/tsung_recorder20140402-1855.xml`.

Выглядит этот файл приблизительно вот так.

```xml
<session name='rec20140402-1908' probability='100'  type='ts_http'>
<request><http url='http://localhost:4567/' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/modernizr-2.0.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/images/line-tile.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<request><http url='http://www.google-analytics.com/__utm.gif?utmwv=5.4.8&amp;utms=14&amp;utmn=652893960&amp;utmhn=localhost&amp;utmcs=UTF-8&amp;utmsr=1440x900&amp;utmvp=1436x791&amp;utmsc=24-bit&amp;utmul=en-gb&amp;utmje=1&amp;utmfl=12.0%20r0&amp;utmdt=%D0%A2%D0%B5%D1%85%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%20%D0%B7%D0%B0%D0%BC%D0%B5%D1%82%D0%BA%D0%B8%20%D0%BE%D0%B4%D0%BD%D0%BE%D0%B3%D0%BE%20%D0%95%D0%B2%D1%82%D1%83%D1%85%D0%BE%D0%B2%D0%B8%D1%87%D0%B0&amp;utmhid=1795243922&amp;utmr=0&amp;utmp=%2F&amp;utmht=1396451305551&amp;utmac=UA-28012309-1&amp;utmcc=__utma%3D111872281.1944978080.1358763093.1396030618.1396449754.56%3B%2B__utmz%3D111872281.1358763093.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&amp;utmu=q~' version='1.1' method='GET'></http></request>
<request><http url='/__utm.gif?utmwv=5.4.8&amp;utms=14&amp;utmn=652893960&amp;utmhn=localhost&amp;utmcs=UTF-8&amp;utmsr=1440x900&amp;utmvp=1436x791&amp;utmsc=24-bit&amp;utmul=en-gb&amp;utmje=1&amp;utmfl=12.0%20r0&amp;utmdt=%D0%A2%D0%B5%D1%85%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%20%D0%B7%D0%B0%D0%BC%D0%B5%D1%82%D0%BA%D0%B8%20%D0%BE%D0%B4%D0%BD%D0%BE%D0%B3%D0%BE%20%D0%95%D0%B2%D1%82%D1%83%D1%85%D0%BE%D0%B2%D0%B8%D1%87%D0%B0&amp;utmhid=1795243922&amp;utmr=0&amp;utmp=%2F&amp;utmht=1396451305551&amp;utmac=UA-28012309-1&amp;utmcc=__utma%3D111872281.1944978080.1358763093.1396030618.1396449754.56%3B%2B__utmz%3D111872281.1358763093.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&amp;utmu=q~' version='1.1' method='GET'></http></request>
<request><http url='/__utm.gif?utmwv=5.4.8&amp;utms=14&amp;utmn=652893960&amp;utmhn=localhost&amp;utmcs=UTF-8&amp;utmsr=1440x900&amp;utmvp=1436x791&amp;utmsc=24-bit&amp;utmul=en-gb&amp;utmje=1&amp;utmfl=12.0%20r0&amp;utmdt=%D0%A2%D0%B5%D1%85%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%20%D0%B7%D0%B0%D0%BC%D0%B5%D1%82%D0%BA%D0%B8%20%D0%BE%D0%B4%D0%BD%D0%BE%D0%B3%D0%BE%20%D0%95%D0%B2%D1%82%D1%83%D1%85%D0%BE%D0%B2%D0%B8%D1%87%D0%B0&amp;utmhid=1795243922&amp;utmr=0&amp;utmp=%2F&amp;utmht=1396451305551&amp;utmac=UA-28012309-1&amp;utmcc=__utma%3D111872281.1944978080.1358763093.1396030618.1396449754.56%3B%2B__utmz%3D111872281.1358763093.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&amp;utmu=q~' version='1.1' method='GET'></http></request>
<request><http url='http://connect.facebook.net/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='http://localhost:4567/images/noise.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<request><http url='http://blog-evtuhovich.disqus.com/count-data.js?2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F06%2F28%2Fpg-stat-statements%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F08%2F03%2Fpartitioning%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F09%2F04%2Fbreaking-news%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F11%2F13%2Fdeflope%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F01%2F04%2Fpodcasts%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F02%2F13%2Fbye-octopress%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F02%2F14%2Fdeep_merge%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F03%2F28%2Fadministrativa%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F03%2F28%2Fknife-solo%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F04%2F02%2Ftsung%2F' version='1.1' method='GET'></http></request>
<request><http url='/count-data.js?2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F06%2F28%2Fpg-stat-statements%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F08%2F03%2Fpartitioning%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F09%2F04%2Fbreaking-news%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2013%2F11%2F13%2Fdeflope%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F01%2F04%2Fpodcasts%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F02%2F13%2Fbye-octopress%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F02%2F14%2Fdeep_merge%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F03%2F28%2Fadministrativa%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F03%2F28%2Fknife-solo%2F&amp;2=http%3A%2F%2Flocalhost%3A4567%2Fblog%2F2014%2F04%2F02%2Ftsung%2F' version='1.1' method='GET'></http></request>

<thinktime random='true' value='21'/>

<request><http url='http://localhost:4567/blog/categories' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/modernizr-2.0.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/images/line-tile.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<request><http url='http://connect.facebook.net/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='http://localhost:4567/images/noise.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<request><http url='http://www.google-analytics.com/__utm.gif?utmwv=5.4.8&amp;utms=15&amp;utmn=1115728760&amp;utmhn=localhost&amp;utmcs=UTF-8&amp;utmsr=1440x900&amp;utmvp=1436x791&amp;utmsc=24-bit&amp;utmul=en-gb&amp;utmje=1&amp;utmfl=12.0%20r0&amp;utmdt=%D0%98%D0%BD%D0%B4%D0%B5%D0%BA%D1%81&amp;utmhid=515038711&amp;utmr=0&amp;utmp=%2Fblog%2Fcategories&amp;utmht=1396451326877&amp;utmac=UA-28012309-1&amp;utmcc=__utma%3D111872281.1944978080.1358763093.1396030618.1396449754.56%3B%2B__utmz%3D111872281.1358763093.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&amp;utmu=q~' version='1.1' method='GET'></http></request>
<request><http url='/__utm.gif?utmwv=5.4.8&amp;utms=15&amp;utmn=1115728760&amp;utmhn=localhost&amp;utmcs=UTF-8&amp;utmsr=1440x900&amp;utmvp=1436x791&amp;utmsc=24-bit&amp;utmul=en-gb&amp;utmje=1&amp;utmfl=12.0%20r0&amp;utmdt=%D0%98%D0%BD%D0%B4%D0%B5%D0%BA%D1%81&amp;utmhid=515038711&amp;utmr=0&amp;utmp=%2Fblog%2Fcategories&amp;utmht=1396451326877&amp;utmac=UA-28012309-1&amp;utmcc=__utma%3D111872281.1944978080.1358763093.1396030618.1396449754.56%3B%2B__utmz%3D111872281.1358763093.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&amp;utmu=q~' version='1.1' method='GET'></http></request>

<thinktime random='true' value='3'/>

<request><http url='http://localhost:4567/blog/categories/rollback/' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/modernizr-2.0.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/images/line-tile.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<request><http url='http://connect.facebook.net/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='/en_US/all.js' version='1.1' method='GET'></http></request>
<request><http url='http://localhost:4567/images/noise.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<request><http url='http://www.google-analytics.com/__utm.gif?utmwv=5.4.8&amp;utms=16&amp;utmn=1214674352&amp;utmhn=localhost&amp;utmcs=UTF-8&amp;utmsr=1440x900&amp;utmvp=1436x791&amp;utmsc=24-bit&amp;utmul=en-gb&amp;utmje=1&amp;utmfl=12.0%20r0&amp;utmdt=%D0%A2%D0%B5%D1%85%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%20%D0%B7%D0%B0%D0%BC%D0%B5%D1%82%D0%BA%D0%B8%20%D0%BE%D0%B4%D0%BD%D0%BE%D0%B3%D0%BE%20%D0%95%D0%B2%D1%82%D1%83%D1%85%D0%BE%D0%B2%D0%B8%D1%87%D0%B0&amp;utmhid=1238120725&amp;utmr=0&amp;utmp=%2Fblog%2Fcategories%2Frollback%2F&amp;utmht=1396451329783&amp;utmac=UA-28012309-1&amp;utmcc=__utma%3D111872281.1944978080.1358763093.1396030618.1396449754.56%3B%2B__utmz%3D111872281.1358763093.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&amp;utmu=q~' version='1.1' method='GET'></http></request>
<request><http url='/__utm.gif?utmwv=5.4.8&amp;utms=16&amp;utmn=1214674352&amp;utmhn=localhost&amp;utmcs=UTF-8&amp;utmsr=1440x900&amp;utmvp=1436x791&amp;utmsc=24-bit&amp;utmul=en-gb&amp;utmje=1&amp;utmfl=12.0%20r0&amp;utmdt=%D0%A2%D0%B5%D1%85%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%20%D0%B7%D0%B0%D0%BC%D0%B5%D1%82%D0%BA%D0%B8%20%D0%BE%D0%B4%D0%BD%D0%BE%D0%B3%D0%BE%20%D0%95%D0%B2%D1%82%D1%83%D1%85%D0%BE%D0%B2%D0%B8%D1%87%D0%B0&amp;utmhid=1238120725&amp;utmr=0&amp;utmp=%2Fblog%2Fcategories%2Frollback%2F&amp;utmht=1396451329783&amp;utmac=UA-28012309-1&amp;utmcc=__utma%3D111872281.1944978080.1358763093.1396030618.1396449754.56%3B%2B__utmz%3D111872281.1358763093.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B&amp;utmu=q~' version='1.1' method='GET'></http></request>


</session>
```

Как видно, в нем много лишнего, давайте почистим его и получим какой-то план тестирования только моего блога.

```xml

<session name='rec20140402-1908' probability='100'  type='ts_http'>
<request><http url='/' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/modernizr-2.0.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
<request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
<request><http url='/images/line-tile.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<request><http url='/images/noise.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
<thinktime random='true' value='21'/>
<request><http url='/blog/categories' version='1.1' method='GET'></http></request>
<thinktime random='true' value='3'/>
<request><http url='/blog/categories/rollback/' version='1.1' method='GET'></http></request>
<thinktime random='true' value='2'/>
<request><http url='/blog/2009/05/19/two-databases/' version='1.1' method='GET'></http></request>
<thinktime random='true' value='2'/>
<request><http url='/life' version='1.1' method='GET'></http></request>
<thinktime random='true' value='3'/>
<request><http url='/about' version='1.1' method='GET'></http></request>
<thinktime random='true' value='2'/>
<request><http url='/' version='1.1' method='GET'></http></request>
<thinktime random='true' value='3'/>
<request><http url='/blog/2014/02/13/bye-octopress/' version='1.1' method='GET'></http></request>
<thinktime random='true' value='3'/>
<request><http url='/blog/archives' version='1.1' method='GET'></http></request>
<thinktime random='true' value='4'/>
<request><http url='/blog/categories/knife/' version='1.1' method='GET'></http></request>
<thinktime random='true' value='2'/>
<request><http url='/' version='1.1' method='GET'></http></request>
</session>

```

Удалим все ненужные нам ресурсы, а для ресурсов блога оставим только url, удалив `http://localhost:4567`. Далее
напишем файл tsung.xml. Я постарался отразить в комментариях в xml все интересные для меня моменты.

```xml
<?xml version="1.0"?>
<!DOCTYPE tsung SYSTEM "/usr/local/Cellar/tsung/1.5.0/share/tsung/tsung-1.0.dtd" >

<tsung loglevel="info" dumptraffic="false" version="1.0">

  <clients>
    <client host="localhost" use_controller_vm="true" maxusers="10000" />
  </clients>

  <!-- Если надо нагружат сразу несколько серверов, то можно указать их список ниже -->
  <servers>
    <server host="localhost" port="4567" type="tcp"></server>
  </servers>

  <load duration="1" unit="hour">
    <arrivalphase phase="1" duration="1" unit="minute">
      <users maxnumber="1000" arrivalrate="1000" unit="minute"></users>
    </arrivalphase>
  </load>

  <options>
    <!-- Сложим в файл urls.csv список всех урлов блога -->
    <option name="file_server" value="urls.csv" id="urls"></option>
  </options>

  <sessions>

    <!-- поскольку боты будут делать только 1 запрос, вес (weight) у них поставим побольше -->
    <session name='bot' weight='30'  type='ts_http'>
      <setdynvars sourcetype="file" fileid="urls" delimiter=";" order="iter">
        <!-- можно использовать как переменную %%_url%% в динамических запросах -->
        <var name="url" />
      </setdynvars>

      <!-- subst="true" обязателен для динамических запросов -->
      <request subst="true">
        <http url='%%_url%%' version='1.1' method='GET'></http></request>
    </session>

    <session name='normal_user' weight='1'  type='ts_http'>
      <!-- здесь мы вставляем сессию из предыдущего примера -->
      <request><http url='/' version='1.1' method='GET'></http></request>
      <request><http url='/javascripts/modernizr-2.0.js' version='1.1' method='GET'></http></request>
      <request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
      <request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
      <request><http url='/javascripts/ender.js' version='1.1' method='GET'></http></request>
      <request><http url='/javascripts/octopress.js' version='1.1' method='GET'></http></request>
      <request><http url='/images/line-tile.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
      <request><http url='/images/noise.png?1392294669' version='1.1' if_modified_since='Sat, 15 Feb 2014 19:50:57 GMT' method='GET'></http></request>
      <thinktime random='true' value='21'/>
      <request><http url='/blog/categories' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='3'/>
      <request><http url='/blog/categories/rollback/' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='2'/>
      <request><http url='/blog/2009/05/19/two-databases/' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='2'/>
      <request><http url='/life' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='3'/>
      <request><http url='/about' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='2'/>
      <request><http url='/' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='3'/>
      <request><http url='/blog/2014/02/13/bye-octopress/' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='3'/>
      <request><http url='/blog/archives' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='4'/>
      <request><http url='/blog/categories/knife/' version='1.1' method='GET'></http></request>
      <thinktime random='true' value='2'/>
      <request><http url='/' version='1.1' method='GET'></http></request>
    </session>
  </sessions>
</tsung>
```

В файл `urls.csv` мы положим список всех урлов сайта, выглядеть он будет приблизительно так.

```
/about/index.html
/blog/2009/01/26/capistrano/index.html
/blog/2009/02/27/continuous-integration/index.html
/blog/2009/03/13/git-move-branch/index.html
/blog/2009/03/20/big-tables/index.html
/blog/2009/03/22/cache-problem/index.html
/blog/2009/03/23/test-and-testing/index.html
/blog/2009/04/03/git-reset/index.html
/blog/2009/04/04/queue/index.html
/blog/2009/04/08/concurent-index/index.html
/blog/2009/04/20/to-yaml-recursion/index.html
/blog/2009/05/19/two-databases/index.html
/blog/2009/05/22/live-table-migration/index.html
/blog/2009/05/28/validates-uniqueness-of/index.html
```

После этого мы запустим tsung. Он будет создавать 1000 пользователей в минуту, причем 30 из них будут ботами, которые
дергают один url, а один — «живым» пользователем, которые будет прокликивать сайт согласно нашему сценарию.

После этого мы запускаем `tsung start`. Он проведет нагрузочное тестирование, а дальше получим результаты с помощью
`tsung_stats.pl` (в OS X он лежит здесь `/usr/local/Cellar/tsung/1.5.0/lib/tsung/bin/tsung_stats.pl`, если вы ставили
tsung из brew). Для этого надо зайти в папку `~/.tsung/log/20140402-1931` в нашем случае и запустить `tsung_stats.pl`.

Он сгенерирует из файла `tsung.log` два html страницы: graph.html и report.html. Там много чего есть, я приведу для
примера только один график оттуда.

![Graph](/images/tsung.png)

Как мы видем, после 60 секунд нагрузка резко падает, и недогулявшией пользователи догуливают по сайту.

А вот два графика из реальной жизни. Как оказалось, чтобы сервер приложений для ruby unicorn работал, как надо,
необходимо немного подпилить параметры ядра Linux (о чем [написано в официальной
документации](http://unicorn.bogomips.org/TUNING.html), но кто ее читает), а именно поставить в sysctl
`net.core.somaxconn=32768` (по-умолчанию он был равен 128). В первом случае лог nginx пестрел вот такими ошибками.

```log
2014/04/01 08:31:12 [error] 21583#0: *168851 recv() failed (104: Connection reset by peer) while reading response header from upstream, client: 54.72.157.44, server: new.project.ru, request: "POST /login HTTP/1.1", upstream: "http://127.0.0.1:8080/login", host: "1.1.1.1"
2014/04/01 08:31:12 [error] 21583#0: *169046 recv() failed (104: Connection reset by peer) while reading response header from upstream, client: 54.72.157.44, server: new.project.ru, request: "GET / HTTP/1.1", upstream: "http://127.0.0.1:8080/", host: "1.1.1.1"
2014/04/01 08:31:12 [error] 21583#0: *171178 recv() failed (104: Connection reset by peer) while reading response header from upstream, client: 54.72.45.113, server: new.project.ru, request: "GET /login HTTP/1.1", upstream: "http://127.0.0.1:8080/login", host: "1.1.1.1"
```

![Плохие настройки](/images/tsung-bad-tune.png)
![Хорошие настройки](/images/tsung-good-tune.png)

Во втором случае видно, как сервер выходит на «насыщение», то есть понятно, на каких нагрузках он перестает справляться.
Гладкие графики — явный признак того, что все работает правильно (наоборот, кстати, тоже верно).

Единственное, что не удалось сделать — это запустить tsung в кластерном режиме работы. По какой-то причине erlang падал и
выдавал crash dump. Разбираться было лень, я запустил параллельно два одинаковых тестовых плана на двух разных серверах.

Так что если вам необходимо создать цунами — дерзайте, все необходимые инструменты для этого есть.
