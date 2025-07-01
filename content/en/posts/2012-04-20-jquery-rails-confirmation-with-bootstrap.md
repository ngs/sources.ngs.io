---
title: ""jquery-rails confirmation with Bootstrap""
date: 2012-04-20T02:15:00+09:00
public: true
tags: ["bootstrap", "rails", "coffee script"]
---


In default", "jquery-rails prompts with native JavaScript `confirm`. That's sucks.

So I overrode `$.rails.fire` method to show Bootstrap style modal instead.

<!--more-->

<script src="https://gist.github.com/ngs/2582950.js"></script>
