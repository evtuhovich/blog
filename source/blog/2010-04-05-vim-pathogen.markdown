---
layout: post
title: Автоматизация vim с помощью pathogen
date: 2010-04-05 00:33
comments: true
categories: 
- vim
- pathogen
---
Извечная проблема о том, как добавлять и обновлять плагины в vim решилась благодаря легендарному Tim Pope.

Сегодня утром узнал от <a href="http://twitter.com/yaroslav">Ярослава Маркина</a> о существовании pathogen.

Статья на английском о том, как им пользоваться, лежит <a
href="http://tammersaleh.com/posts/the-modern-vim-config-with-pathogen">здесь</a>. Правда, я потратил полчаса, чтобы
догадаться, что надо добавить <code>call pathogen#runtime_append_all_bundles()</code> в файл <code>~/.vimrc</code>.

После установки <a href="http://github.com/tpope/vim-pathogen/raw/master/autoload/pathogen.vim">pathogen.vim</a> в
<code>~/.vim/autoload</code> можно хранить все плагины в папке <code>~/.vim/bundle</code>, причем каждый в своей папке.

А еще огромный плюс - в конце этой статьи код, который позволяет обновлять все плагины одной командой.

Конечно, есть некоторые проблемы с vimscripts (потому что туда заливают скрипты как хотят), но это все равно устаревшая
архитектура и это вопрос времени, когда все актуальные плагины переберутся на github.
