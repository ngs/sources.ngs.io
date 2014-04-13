---
layout: post
title: "jquery-rails confirmation with Bootstrap"
date: 2012-04-20 02:15
comments: true
categories: [Bootstrap, Rails, Coffee Script]
---


In default, jquery-rails prompts with native JavaScript `confirm`. That's sucks.

So I overrode `$.rails.fire` method to show Bootstrap style modal instead.

<!--more-->

{% gist 2582950 link.html.erb %}
{% gist 2582950 confirm.js.coffee %}