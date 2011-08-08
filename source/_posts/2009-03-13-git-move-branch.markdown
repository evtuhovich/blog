---           
layout: post
title: Перенести ветку в git
date: 2009-03-13 09:12:00 UTC
comments: false
categories: git rebase git git cherry-pick git branch
published: false
---

<table>
<tr>
<td valign="top">
<a onblur="try {parent.deselectBloggerImageGracefully();} catch(e) {}" href="http://2.bp.blogspot.com/_KDeY2lDahZI/SbolpS9wuTI/AAAAAAAAAUI/kFo8pUQi11c/s1600-h/gitk1.png"><img style="margin:0 0 10px 0;cursor:pointer; cursor:hand;width: 182px; height: 301px;" src="http://2.bp.blogspot.com/_KDeY2lDahZI/SbolpS9wuTI/AAAAAAAAAUI/kFo8pUQi11c/s400/gitk1.png" border="0" alt=""id="BLOGGER_PHOTO_ID_5312600101832669490" /></a>
<strong>Картинка 1</strong>

<a onblur="try {parent.deselectBloggerImageGracefully();} catch(e) {}" href="http://3.bp.blogspot.com/_KDeY2lDahZI/SbomWrGgLGI/AAAAAAAAAUQ/wB5w9eEGFQ0/s1600-h/gitk2.png"><img style="margin:0 0 10px 0;cursor:pointer; cursor:hand;width: 157px; height: 398px;" src="http://3.bp.blogspot.com/_KDeY2lDahZI/SbomWrGgLGI/AAAAAAAAAUQ/wB5w9eEGFQ0/s400/gitk2.png" border="0" alt=""id="BLOGGER_PHOTO_ID_5312600881405897826" /></a>
<strong>Картинка 2</strong>

<a onblur="try {parent.deselectBloggerImageGracefully();} catch(e) {}" href="http://4.bp.blogspot.com/_KDeY2lDahZI/SbomcHuTuUI/AAAAAAAAAUY/0RatFSWqDCA/s1600-h/git3.png"><img style="margin:0 0 10px 0;cursor:pointer; cursor:hand;width: 156px; height: 400px;" src="http://4.bp.blogspot.com/_KDeY2lDahZI/SbomcHuTuUI/AAAAAAAAAUY/0RatFSWqDCA/s400/git3.png" border="0" alt=""id="BLOGGER_PHOTO_ID_5312600974988392770" /></a>
<strong>Картинка 3</strong>

</td><td valign="top" style="vertical-align: top">
Представим следующую ситуацию (она постоянно возникает у нас при разработке). У нас есть ветка master в git, а в день релиза мы создаем ветку b1. Мы добавляем какие-то изменения в ветки b1 и master. И тут вдруг (хотя слово "вдруг" не очень подходит к регулярным событям) менеджмент решает добавить что-то из master в релиз. Если комитов было мало, то можно воспользоваться git cherry-pick (если их несколько, то может помочь ключ -n). А что делать, если комитов было больше 10? Рукаме делать git cherry-pick не очень удобно. В таком случае нам поможет (в который раз) git rebase.

Итак, вначале у нас было ситуация с картинки 1.

И нам необходимо добавить часть комитов из master в b1, начиная с m10, но не все.
<pre>
git checkout master
git checkout -b b2
git rebase -i --onto b1 f9e4819a40c58985ce183a135a473a9bfd654ff4 b2
</pre>
Последнюю команду стоит понимать следующим образом: «прицепить к ветку b1 все между f9e4819a40c58985ce183a135a473a9bfd654ff4 и b2 и назвать это b2». Если не создать ветку b2, то такая команда прицепит к b1 ветку master, вряд ли это то, что нам нужно.

Здесь f9e4819a40c58985ce183a135a473a9bfd654ff4 — это sha комита m7. Далее в открывшемся тектовом редакторе оставляем комиты, которые нам нужны. После этого мы имеем картинку 2.

Дальнейшее не составит труда даже для ребенка
<pre>
git checkout b1
git merge b2
</pre>


Ветку b2 можно теперь удалить.
</td></tr></table><div class="blogger-post-footer"><img width='1' height='1' src='https://blogger.googleusercontent.com/tracker/12147316-365559815959317354?l=evtuhovich.blogspot.com' alt='' /></div>
