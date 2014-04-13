---
title: jQuery CrossDomain AJAX Plugin
description: jQuery CrossDomain AJAX Plugin
date: 2009-07-13 22:52
public: true
tags: javascript, jquery, jui, mtl, plugin
---

金曜日、MTL の Cafe で行われた、[JUI 2009 Returns][jui] で発表したプラグインについてです。

かなりパツっていて、詳細を話せなかったので、こちらで補足します。(思いつき次第追記します。)

ソースは以下でホスティングしてもらってます。

[jqcrossdomain on Google Code][gc]

以下がスライドです。

<iframe src="http://docs.google.com/present/embed?id=dd24m8qr_530g6pwrzfd&amp;size=m" frameborder="0" width="555" height="451"></iframe></p>

READMORE

こちら、裏側がSWFになっているので、SWFObject 2.X が必要です。  
->今後、Detection 機能を実装したいと思っています。

もちろん jQuery も必要です。現段階では、1.3 で検証をおこなっています。

スライド #9 のとおり、jQuery の AJAX メソッドは全て使えるようにしようと思っています。

http://docs.jquery.com/Ajax

今のところ、追加機能として、`ajaxSettings` で crossdomain.xml の場所が指定できます。

```js
$.ajax({
    type: "xml",
    url: API_AREAS + "?key=" + apiKey,
    policyFile: "http://jws.jalan.net/crossdomain.xml",
    success: function(d) {
        onLoadRegions(getList($("Region", d)));
    }
});
```

このライブラリを使って、ActionScript 3.0 の `URLLoader` クラスメソッドを全て使えるようにもしたいと思っています。

ドキュメント筆者 (言語問わず) や共同開発者絶賛募集中です。

### Demoはこちら

* [じゃらんウェブサービス]
* [Kuler]

### 当日の様子はこちら

[The JUI 2009 Returns カンファレンスを開催しました！ : Media Technology Labs (MTL) : メディアテクノロジーラボ　ブログ][report]


[jui]: http://mtl.recruit.co.jp/blog/2009/07/javascript_the_jui_2009_return.html
[gc]: http://code.google.com/p/jqcrossdomain/
[じゃらんウェブサービス]: http://jqcrossdomain.googlecode.com/svn/trunk/tests/jws.html
[Kuler]: http://jqcrossdomain.googlecode.com/svn/trunk/tests/kuler.html
[report]: http://mtl.recruit.co.jp/blog/2009/07/the_jui_2009_returns.html
