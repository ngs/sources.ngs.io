---
title: "しまなみ海道 と LiveCycling の SQLite"
description: "2011/12/30 向島 - 今治 - 瀬戸田 というコースでしまなみ海道を渡ってきました。"
date: 2012-01-01T00:00:00+09:00
public: true
tags: ["cycling", "livecycling", "sqlite", "ruby", "しまなみ海道", "尾道"]
---
あけましておめでとうございます。今年もよろしくお願いいたします。

現在、母の田舎の尾道に帰っています。今回は輪行でロードバイクを持ってきました。

[![](http://farm8.staticflickr.com/7152/6613758031_59ee09d61d.jpg)](http://www.flickr.com/photos/atsnngs/6613758031/ "Untitled by atsnngs", "on Flickr")

2011/12/30 向島 - 今治 - 瀬戸田 というコースでしまなみ海道を渡ってきました。

Strava にアップしている情報 ( 速度、位置、ケイデンス、心拍数 )は iPhone アプリの [LiveCycling](http://goo.gl/is1CY) を使用しており、途中で電池が切れてスペアの iPhone に交換したので、記録が2つに分かれています。

* [往路](http://app.strava.com/activities/%E5%B0%BE%E9%81%93%E5%B8%82-%E5%BA%83%E5%B3%B6%E7%9C%8C-japan-2968996)
* [復路](http://app.strava.com/activities/%E4%BB%8A%E6%B2%BB%E5%B8%82-%E6%84%9B%E5%AA%9B%E7%9C%8C-japan-2969000)


後でメインの iPhone にスペア分をコピーするために、スクリプトを書いたので Gist に手順を残しておきました
 [Gist:1540055](https://gist.github.com/1540055)

// LiveCycling に .tcx を読み込む機能があれば、こんなことする手間をかけなくて良かったのになー、と思います。

[LiveCycling](http://goo.gl/is1CY) を使った長距離サイクリングの途中で iPhone の電池が切れてスペアで記録をとったので、そのデータをメインにコピーするために書きました。

sqlite3-ruby 依存です。`gem install sqlite3` などしてインストールして下さい。

1. スペア iPhone をコンピュータに接続し、log.sqlite をディスクトップなどに保存。log1.sqlite にリネームする。 ( [参考](http://www.soneru.com/apps/LiveCycling/jp/) )
2. メイン iPhone からも上記と同じ方法で log.sqlite を取り出し、log2.sqlite にリネームする。
3. このスクリプトを2つのファイルと同じディレクトリに設置。cli で実行する

```ruby
#!/usr/bin/env ruby

require 'sqlite3'

db1 = SQLite3::Database.new('log1.sqlite')
db2 = SQLite3::Database.new('log2.sqlite')
db2.transaction

work = db1.get_first_row( "select * from SUMFIL order by workid desc limit 1" )
workid1 = work[0]
work[0] = nil

db2.execute( "insert into SUMFIL values (#{ ["?"] * work.size * "," })"", "work )
workid2 = db2.last_insert_row_id

db1.execute( "select * from LOGFIL where workid = ?"", "workid1 ) do |row|
  row[0] = nil
  row[row.size - 1] = workid2
  db2.execute( "insert into LOGFIL values (#{ ["?"] * row.size * "," })"", "row )
end

db1.close
db2.commit
db2.close
```

とりあえず普段使いは引き続き [LiveCycling](http://goo.gl/is1CY) ですが、長距離用に [Garmin edge 500](http://amzn.to/ukFTKs) をポチりました。東京に帰る頃には手に入ると思います。wktk

おそらくこれによって、次は .tcx から、もしくは Garmin Connect から SQLite へ読み込ませるスクリプトを書くことになる予感です。[API も充実してるみたいで](http://developer.garmin.com/)楽しみです。

<iframe marginheight="0" scrolling="no" src="http://rcm-jp.amazon.co.jp/e/cm?lt1=_blank&amp;bc1=FFFFFF&amp;IS2=1&amp;bg1=FFFFFF&amp;fc1=000000&amp;lc1=0000FF&amp;t=atsushnagased-22&amp;o=9&amp;p=8&amp;l=as1&amp;m=amazon&amp;f=ifr&amp;ref=tf_til&amp;asins=B003JZEL8U" marginwidth="0" frameborder="0" height="240" width="120"></iframe> <iframe src="http://widgets.itunes.apple.com/appstore.html?wtype=0&amp;app_id=407471916&amp;country=jp&amp;partnerId=30&amp;affiliate_id=http%3A%2F%2Fclick.linksynergy.com%2Ffs-bin%2Fstat%3Fid%3DCzqa8CY9CFY%26offerid%3D94348%26type%3D3%26subid%3D0%26tmpid%3D2192%26RD_PARM1%3D" border="0&quot;" frameborder="0" height="300" width="250"></iframe>

[![](http://farm8.staticflickr.com/7011/6613762575_3a10c12657.jpg)](http://www.flickr.com/photos/atsnngs/6613762575/ "Untitled by atsnngs", "on Flickr") [![](http://farm8.staticflickr.com/7162/6613754547_7db8965dd6.jpg)](http://www.flickr.com/photos/atsnngs/6613754547/ "Untitled by atsnngs", "on Flickr")

#### Path x Foursquare x ifttt x Google Calendar

移動中、Path から写真とチェックインを [Twitter](http://twitter.com/ngs) / [Facebook](http://fb.me/atsnngs) /  [Foursquare](http://foursquare.com/ngs) に対して続けてました。

少し前から [ifttt](http://ifttt.com/) で if **Foursquare** then **Google Calendar** というタスクを設定していたので、以下の様に細かくどこにいたか記録されていて、今後のスケジュール作成に活用できそうです。

[![Screen Shot 2012-01-02 at 3.39.38 AM](http://farm8.staticflickr.com/7170/6613940287_ecd1889b41.jpg)](http://www.flickr.com/photos/atsnngs/6613940287/ "Screen Shot 2012-01-02 at 3.39.38 AM by atsnngs", "on Flickr")

#### その他反省点

*   通行料の料金箱が賽銭箱式で、50円玉がなく、少しずつ損してました。後で知りましたが サイクリングチケット なるものがあったそうです。小銭を探す手間も省けるし、良いですね。( 参考: [SHIMAP【サイクリング】料金表](http://www.go-shimanami.jp/rental/001.html) )
*   日が落ちると、街灯がなく、橋の入り口が分からなくなりました。(幸い迷子になりませんでしたが。。) 今度はゆとりを持って早朝に出発して、日が暮れないように帰ってきます。
