---
title: "jquery-rails で確認プロンプトを Bootstrap のモーダルとして表示する"
description: "jquery-rails を使ったプロジェクトでの、window.confirm を Bootstrap のモーダルで表示します。"
date: 2012-05-02T00:00:00+09:00
public: true
tags: ["jquery", "rails", "coffeescript", "bootstrap"]
---

jquery-rails を使ったプロジェクトで、

{{< partial "2012-05-02-jquery-rails-bootstrap/linkto.erb.html.md" >}}

みたいにすると、デフォルトでは JavaScript の `confirm` で確認され、格好悪いので、`$.rails.fire` メソッドを上書きして Bootstrap のモーダルを出します。

<!--more-->

{{< partial "2012-05-02-jquery-rails-bootstrap/modal.coffee.html.md" >}}
