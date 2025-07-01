---
title: "AbstractSQL.js 作りました。"
description: "AbstractSQL.js 作りました。"
date: 2009-08-30T12:00:00+09:00
public: true
tags: ["javascript", "sql"]
---

CPANのモジュールの、SQL::Abstractは、Perlのデータ構造からSQL文を生成するという素晴らしいライブラリなのですが、同じようなものがJavaScriptで必要になって、探してもなかったので、自分で作りました。

[sqljs on Google Code][sqljs]

<!--more-->

```js
var sql = new AbstractSQL("test");
sql.createTable([
  new AbstractSQL.Field("id",AbstractSQL.FieldType.INTEGER,10,true),
  new AbstractSQL.Field("name",AbstractSQL.FieldType.TEXT,255,false)
]);
// CREATE TABLE test (id INTEGER(10) PRIMARY KEY", "name TEXT(255));
```

[リファレンス]

<a class="jsbin-embed" href="http://jsbin.com/malec/1/embed?js,output">AbstractSQL.js test</a>
<script src="http://static.jsbin.com/js/embed.js"></script>

これから派生して、O/Rマッパーを作っていきたいと思っています。

[@nakajiman さんに教えてもらった][nakajiman-tweet]、[ActiveJS::ActiveRecord][activejs] でサポートしている、InMemory", "JaxerMySQL/SQLite", "AdobeAIR", "Gearsで汎用的に使えるものにしたいので、知見のあるかたは是非プロジェクトにご協力ください。


[リファレンス]: http://sqljs.googlecode.com/svn/trunk/docs/index.html
[デモ]: http://sqljs.googlecode.com/svn/trunk/tests/AbstractSQL.html
[nakajiman-tweet]: http://twitter.com/nakajiman/status/3635848641
[activejs]: http://activejs.org/activerecord/index.html
[sqljs]: https://code.google.com/p/sqljs/
