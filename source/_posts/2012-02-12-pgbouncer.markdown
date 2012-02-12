---
layout: post
title: "PgBouncer"
date: 2012-02-12 23:04
comments: true
categories: 
- pgbouncer
- connection pool
---

{% pullquote %}
Удивительное дело, что я до сих пор не написал про [PgBouncer](http://pgfoundry.org/projects/pgbouncer/). Как написано
на сайте — это «Lightweight connection pooler for PostgreSQL». Я бы первел это следующим образом.
{" PgBouncer — это легкий менеджер соединений для PostgreSQL. "}
{% endpullquote %}

Дело в том, что postgres для каждого соединения создает новый процесс. Это не проблема, если у вас запущено несколько
процессов с вашим приложением. Но если ваша система достаточно велика, то сотни процессов postgres, запущенные на одной,
пусть даже и мощной, машине, будут впустую тратить память и процессорное время.
