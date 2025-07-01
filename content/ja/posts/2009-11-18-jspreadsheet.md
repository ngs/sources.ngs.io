---
title: "Google Spreadsheetのデータを簡単に取得できる jQuery プラグイン - jSpreadSheet"
description: "Google Spreadsheet のデータを簡単に取得できる jQuery プラグイン jSpreadSheet を作りました。"
date: 2009-11-18T02:10:00+09:00
public: true
tags: ["javascript", "jquery", "spreadsheets", "google"]
---

Google Spreadsheet のデータを簡単に取得できる jQuery プラグイン [jSpreadSheet][gh] を作りました。

[ngs/jSpreadSheet on GitHub][gh]


[以前にも同じ事をやってた方 (リンク切れ)][wakasa] がいらっしゃったようなのですが、SQL がたたけなかったりと、欲しいものと違っていたので、1から作成しました。

このプラグインを使うと、Google の `jsapi` と `google.load("visualization"", ""1");` の記述が省略できます。

※ 基礎的な使い方は [WebOS Goodies さんのエントリー][webos-goodies]にとてもわかりやすく掲載されています。

使い方は以下のような感じ

```js
$.ss("http://spreadsheets.google.com/tq?key=0ArNMycobpXr3ckJybUNHVDZ0cEU0SjZvb0prVDhGS2c")
  .setQuery("select * where B like 'test%'")
  // クエリは省略可能です。省略すると全件取ってきます。
  .setField("time,title,address,foo,bar,buz,hoge")
  // ここで設定した値がレコードオブジェクトの変数名になります。
  // 省略すると、配列番号として格納されます。
  .send(function(success){
    // おなじみeach関数でレコードをループできます。
    this.each(function(i){
      console.log( i", "this.title );
    });
  })
```

<a class="jsbin-embed" href="http://jsbin.com/bidoj/1/embed?output">jSpreadSheet Demo</a>
<script src="http://static.jsbin.com/js/embed.js"></script>

[元ネタの sheet はこちら。][sheet]

[フォームからデータを投稿できます。][form]


[webos-goodies]: http://webos-goodies.jp/archives/51310352.html
[wakasa]: http://wakasa.org/archives/2008/11/spreadsheetsjav.html
[demo]: http://ngs.github.io/jSpreadSheet/
[gh]: https://github.com/ngs/jSpreadSheet/
[sheet]: https://docs.google.com/spreadsheet/ccc?key=0ArNMycobpXr3ckJybUNHVDZ0cEU0SjZvb0prVDhGS2c&usp=sharing
[form]: https://docs.google.com/spreadsheet/viewform?formkey=ckJybUNHVDZ0cEU0SjZvb0prVDhGS2c6MA..#gid=0
