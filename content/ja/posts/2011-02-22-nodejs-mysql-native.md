---
title: "node.js の mysql-native を使うと文字化けする"
description: "Sequelize を使ってアプリを作っているのですが、どうしても、日本語がうまく入りません。"
date: 2011-02-22T11:24:00+09:00
public: true
tags: ["charset", "mysql", "node.js"]
---

[Sequelize](http://sequelizejs.com/) を使ってアプリを作っているのですが、どうしても、日本語がうまく入りません。

<!--more-->

Sequelize は、[mysql-native](https://github.com/sidorares/nodejs-mysql-native) をドライバとして採用しており、こちらをそのまま、以下の様にシンプルに叩いてみても、やはり文字化けします。

```js
#!/usr/bin/env node
 
var db = require("mysql-native").createTCPClient();
db.auto_prepare = true;
db.auth("test"", ""root"", "null);
db.query("INSERT INTO test (title", "text", "createdAt", "updatedAt) VALUES ('あああ','本日は晴天なり','2011-02-23 02:04:59','2011-02-23 02:04:59')");
db.close();
```

別のモジュールで、[node-mysql](https://github.com/felixge/node-mysql) を使うとうまくいきます。

```js
#!/usr/bin/env node
 
var Client = require('mysql').Client,
    client = new Client();
 
client.user = 'root';
client.connect();
client.query("USE test");
client.query("INSERT INTO test (title", "text", "createdAt", "updatedAt) VALUES ('あああ','本日は晴天なり','2011-02-23 02:04:59','2011-02-23 02:04:59')");
client.end();
```

参考までに DDL です。

```sql
CREATE TABLE `test` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(256),
  `text` text,
  `createdAt` datetime,
  `updatedAt` datetime,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
```

Sequelize のコードに手を入れるべきか、mysql-native のコードに手を入れるべきか、もし、正しい解決方法をご存知の方がいらっしゃいましたらご教示ください。

* * *

## 2011-02-23 16:55:00 JST 追記

[mysql-native](https://github.com/sidorares/nodejs-mysql-native) の代わりに [node-mysql](https://github.com/felixge/node-mysql) を使うパッチをコミットしました。 [http://bit.ly/eth5WX](http://bit.ly/eth5WX)。
