---
title: Yo と IRKit を使って家電を操作する
description: hubot-irkit 0.2.0 で webhook を受けられる機能追加を行ったので、ウェブサービスと家電を簡単に連携できるようになりました。
date: 2014-09-07 12:20
public: true
tags: hubot, irkit, roomba, yo, api
alternate: false
ogp:
  og:
    image:
      '': 2014-09-07-irkit-yo/yo-irkit-roomba.jpg
      type: image/jpeg
      width: 1920
      height: 1080
    video:
      '': http://vimeo.com/moogaloop.swf?clip_id=105457095
      secure_url: https://vimeo.com/moogaloop.swf?clip_id=105457095
      type: application/x-shockwave-flash
      width: 640
      height: 360
---

<iframe src="//player.vimeo.com/video/105457095?title=0&amp;byline=0&amp;badge=0" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen class="vimeo"></iframe>

動画は [Yo API] のコールバックを契機に [Roomba] を起動するデモです。

[Hubot] に [IRKit] 関連のコマンドを追加する、[hubot-irkit] のバージョン 0.2.0 をリリースしました。

このバージョンアップで webhook を受けられる機能追加を行ったので、ウェブサービスと家電を簡単に連携できるようになりました。

READMORE

セットアップ方法
-------------

[Hubot] へのセットアップの手順は以前の記事を参照してください。 **[hubot-irkit で Hubot と対話しながら IRKit を操作する。]**

Heroku を使っている場合は `heroku` コマンドで環境変数をセットし webhook を有効化します。

```bash
heroku config:set HUBOT_IRKIT_HTTP=1
```

以下の様なルーティングで webhook を受け付けます。

```
GET /irkit/messages/:deviceName/:messageName
```

デフォルトの HTTP メソッドは `GET` ですが、`HUBOT_IRKIT_HTTP_METHOD` 環境変数で変更できます。([参照][HUBOT_IRKIT_HTTP_METHOD])

上の動画の様に連携させる場合、Roomba のリモコン信号を、`living` というデバイスに、`roomba` というメッセージで登録します。

```
me > hubot ir register message roomba for living
hubot > Waiting for IR message...

-- ここで IRKit に向けて信号を送ります --

hubot > Message: robot for living is successfully registered.
```

[Hubot] をホスティングしている URL にアクセスすると、`OK` という文字がでてきて、[Roomba] が [IRKit] の信号の届く範囲にいれば、掃除を始めます。

```bash
$ curl -i http://myhubot.herokuapp.com/irkit/messages/living/roomba

HTTP/1.1 200 OK
Server: Cowboy
Connection: keep-alive
X-Powered-By: hubot/Hubot
Content-Type: text/html; charset=utf-8
Content-Length: 2
Date: Sun, 07 Sep 2014 03:10:06 GMT
Via: 1.1 vegur

OK
```

この URL を [Yo の開発者ダッシュボード] で Callback URL に設定します。

![](yoapi.png)

これで、動画の様に [Yo] で [Roomba] を起動できます。

<script> window.setupAmazonWidget('関連商品', 'B00H91KK26', 'B00L8LVJ7S') </script>
<script src='https://wms-fe.amazon-adsystem.com/20070822/JP/js/AmazonWidgets.js'></script>

[hubot-irkit]: https://github.com/ngs/hubot-irkit
[hubot-irkit で Hubot と対話しながら IRKit を操作する。]: /2014/06/09/hubot-irkit/
[Roomba]: http://www.irobot-jp.com/
[Yo API]: https://medium.com/@YoAppStatus/e7f2f0ec5c3c
[Hubot]: https://hubot.github.com/
[IRKit]: http://getirkit.com/
[ngs/hubot-irkit]: https://github.com/ngs/hubot-irkit
[HUBOT_IRKIT_HTTP_METHOD]: https://github.com/ngs/hubot-irkit#hubot_irkit_http_method
[Yo]: http://www.justyo.co/
[Yo の開発者ダッシュボード]: http://dev.justyo.co/
