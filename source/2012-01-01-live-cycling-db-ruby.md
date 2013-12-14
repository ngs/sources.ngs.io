---
title: しまなみ海道 と LiveCycling の SQLite
description: 2011/12/30 向島 - 今治 - 瀬戸田 というコースでしまなみ海道を渡ってきました。
date: 2012-01-01 00:00
public: true
tags: cycling, LiveCycling, sqlite, ruby, しまなみ海道, 尾道
---
あけましておめでとうございます。今年もよろしくお願いいたします。

現在、母の田舎の尾道に帰っています。今回は輪行でロードバイクを持ってきました。

[![](http://farm8.staticflickr.com/7152/6613758031_59ee09d61d.jpg)](http://www.flickr.com/photos/atsnngs/6613758031/ "Untitled by atsnngs, on Flickr")

2011/12/30 向島 - 今治 - 瀬戸田 というコースでしまなみ海道を渡ってきました。

Strava にアップしている情報 ( 速度、位置、ケイデンス、心拍数 )は iPhone アプリの [LiveCycling](http://goo.gl/is1CY) を使用しており、途中で電池が切れてスペアの iPhone に交換したので、記録が2つに分かれています。

<iframe scrolling="no" src="http://app.strava.com/runs/2968996/embed/13d42a6ddc4e3161a9060a85af0cc8a8c458398c" frameborder="0" height="405" width="500"></iframe> <iframe scrolling="no" src="http://app.strava.com/runs/2969000/embed/52b7b944474a468a161bf268f1367f886509064a" frameborder="0" height="405" width="500"></iframe>

後でメインの iPhone にスペア分をコピーするために、スクリプトを書いたので Gist に手順を残しておきました
 [Gist:1540055](https://gist.github.com/1540055)

// LiveCycling に .tcx を読み込む機能があれば、こんなことする手間をかけなくて良かったのになー、と思います。

<script src="https://gist.github.com/1540055.js?file=README.mkdn"></script>
<script src="https://gist.github.com/1540055.js?file=import.rb"></script>

とりあえず普段使いは引き続き [LiveCycling](http://goo.gl/is1CY) ですが、長距離用に [Garmin edge 500](http://amzn.to/ukFTKs) をポチりました。東京に帰る頃には手に入ると思います。wktk

おそらくこれによって、次は .tcx から、もしくは Garmin Connect から SQLite へ読み込ませるスクリプトを書くことになる予感です。[API も充実してるみたいで](http://developer.garmin.com/)楽しみです。

<iframe marginheight="0" scrolling="no" src="http://rcm-jp.amazon.co.jp/e/cm?lt1=_blank&amp;bc1=FFFFFF&amp;IS2=1&amp;bg1=FFFFFF&amp;fc1=000000&amp;lc1=0000FF&amp;t=atsushnagased-22&amp;o=9&amp;p=8&amp;l=as1&amp;m=amazon&amp;f=ifr&amp;ref=tf_til&amp;asins=B003JZEL8U" marginwidth="0" frameborder="0" height="240" width="120"></iframe> <iframe src="http://widgets.itunes.apple.com/appstore.html?wtype=0&amp;app_id=407471916&amp;country=jp&amp;partnerId=30&amp;affiliate_id=http%3A%2F%2Fclick.linksynergy.com%2Ffs-bin%2Fstat%3Fid%3DCzqa8CY9CFY%26offerid%3D94348%26type%3D3%26subid%3D0%26tmpid%3D2192%26RD_PARM1%3D" border="0&quot;" frameborder="0" height="300" width="250"></iframe>

[![](http://farm8.staticflickr.com/7011/6613762575_3a10c12657.jpg)](http://www.flickr.com/photos/atsnngs/6613762575/ "Untitled by atsnngs, on Flickr") [![](http://farm8.staticflickr.com/7162/6613754547_7db8965dd6.jpg)](http://www.flickr.com/photos/atsnngs/6613754547/ "Untitled by atsnngs, on Flickr")

#### Path x Foursquare x ifttt x Google Calendar

移動中、Path から写真とチェックインを [Twitter](http://twitter.com/ngs) / [Facebook](http://fb.me/atsnngs) /  [Foursquare](http://foursquare.com/ngs) に対して続けてました。

少し前から [ifttt](http://ifttt.com/) で if **Foursquare** then **Google Calendar** というタスクを設定していたので、以下の様に細かくどこにいたか記録されていて、今後のスケジュール作成に活用できそうです。

[![Screen Shot 2012-01-02 at 3.39.38 AM](http://farm8.staticflickr.com/7170/6613940287_ecd1889b41.jpg)](http://www.flickr.com/photos/atsnngs/6613940287/ "Screen Shot 2012-01-02 at 3.39.38 AM by atsnngs, on Flickr")

#### その他反省点

*   通行料の料金箱が賽銭箱式で、50円玉がなく、少しずつ損してました。後で知りましたが サイクリングチケット なるものがあったそうです。小銭を探す手間も省けるし、良いですね。( 参考: [SHIMAP【サイクリング】料金表](http://www.go-shimanami.jp/rental/001.html) )
*   日が落ちると、街灯がなく、橋の入り口が分からなくなりました。(幸い迷子になりませんでしたが。。) 今度はゆとりを持って早朝に出発して、日が暮れないように帰ってきます。