---
layout: post
title: "Caches-action"
date: 2011-08-22 13:02
comments: true
categories:
- rails
- 2.3
- caches_action
published: false
---


+  caches_action :show, :expires_in => 3.minutes, :layout => Proc.new { |c| c.request.xhr? },
+    :cache_path => Proc.new { |c| c.params.merge!("xhr" => c.request.xhr?.to_s) }

http://railsforum.com/viewtopic.php?id=41906
