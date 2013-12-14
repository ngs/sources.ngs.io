---
title: node.js の mysql-native を使うと文字化けする
description: Sequelize を使ってアプリを作っているのですが、どうしても、日本語がうまく入りません。
date: 2011-02-22 11:24
public: true
tags: charset, mysql, node.js
---

[Sequelize](http://sequelizejs.com/) を使ってアプリを作っているのですが、どうしても、日本語がうまく入りません。

Sequelize は、[mysql-native](https://github.com/sidorares/nodejs-mysql-native) をドライバとして採用しており、こちらをそのまま、以下の様にシンプルに叩いてみても、やはり文字化けします。

<p>[https://gist.github.com/839181.js?file=test-mysql-native](https://gist.github.com/839181.js?file=test-mysql-native)
</p>

別のモジュールで、[node-mysql](https://github.com/felixge/node-mysql) を使うとうまくいきます。

<p>[https://gist.github.com/839181.js?file=test-mysql](https://gist.github.com/839181.js?file=test-mysql)
</p>

参考までに DDL です。

<script src="https://gist.github.com/839181.js?file=schema.sql"></script>

Sequelize のコードに手を入れるべきか、mysql-native のコードに手を入れるべきか、もし、正しい解決方法をご存知の方がいらっしゃいましたらご教示ください。

* * *

## 2011-02-23 16:55:00 JST 追記

[mysql-native](https://github.com/sidorares/nodejs-mysql-native) の代わりに [node-mysql](https://github.com/felixge/node-mysql) を使うパッチをコミットしました。 [http://bit.ly/eth5WX](http://bit.ly/eth5WX)。
