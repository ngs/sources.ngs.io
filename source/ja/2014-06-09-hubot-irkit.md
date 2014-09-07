---
title: hubot-irkit で Hubot と対話しながら IRKit を操作する。
description: Hubot で IRKit を操作するスクリプトを作りました。
date: 2014-06-09 06:00
public: true
tags: hubot, irkit, gadget
alternate: false
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2014-06-09-hubot-irkit/picture.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2014-06-09-hubot-irkit/picture.jpg)

何か [Hubot] とハードウェアが連携するものを作りたかったので、既に、仕事部屋とリビングに2台所有している、オープンソース赤外線リモコンデバイス [IRKit] を操作するスクリプトを作りました。

**[ngs/hubot-irkit]**

READMORE

コマンド
------

こんな感じで操作します。

```bash
# オフィスのアンプを登録する
me > hubot irkit register device XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX office-amp
hubot > Registering client: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX as office-amp...
hubot > Device: office-amp is successfully registered.

# 電源オンボタンを登録する
me > hubot irkit register message poweron for office-amp
hubot > Waiting for IR message... # ここで IRKit に向けてリモコン操作
hubot > Message: poweron for office-amp is successfully registered.

# 電源オン信号をアンプに送信する
me > hubot irkit send message poweron for office-amp
hubot > Sending poweron for office-amp..
hubot > Successfully sent message: poweron for office-amp
```

登録したデバイス、メッセージは [Hubot] の [brain] に保存されます。

`redis-brain` を使っている場合は、Redis に `hubot:storage` というキーで JSON データが保存されます。

インストール
----------

このスクリプトを追加するには `npm install` コマンドを [Hubot] ディレクトリで実行して、

```bash
npm install --save hubot-irkit
```

`hubot-irkit` を `external-scripts.json` に追加してください。

```json
["hubot-irkit"]
```

セットアップ手順
-------------

### 1. IRKit を入手する

大前提ですが、IRKit 本体が必要です。もしよろしければ、[アフェリエイトリンク]からお買い上げ下さい :)

家に届いたら、公式アプリのセットアップ手順にしたがって、ローカルネットワークに接続してください。

### 2. クライアントトークンを取得する

[オフィシャルドキュメント]に記載されている通り、`dns-sd` コマンドで `Instance Name` を見つけます。


```bash
dns-sd -B _irkit._tcp
```

こんなレスポンスが返ってきます。

```
Browsing for _irkit._tcp
DATE: ---Mon 09 Jun 2014---
 1:22:43.931  ...STARTING...
Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
 1:22:44.104  Add        2   4 local.               _irkit._tcp.         irkita1EC
 1:22:44.105  Add        2   4 local.               _irkit._tcp.         iRKit928E
```

`Instance Name`　を選んで、`.local` の接尾辞をつけて、アドレスを調べます。

```bash
dns-sd -G v4 irkita1EC.local
```

```
DATE: ---Mon 09 Jun 2014---
 1:24:14.248  ...STARTING...
Timestamp     A/R Flags if Hostname                               Address                                      TTL
 1:24:14.524  Add     2  4 irkita1ec.local.                       192.168.1.29                                 10
```

クライアントトークンを取得します。

```bash
curl -i -XPOST http://192.168.1.29/keys
```

```
HTTP/1.0 200 OK
Access-Control-Allow-Origin: *
Server: IRKit/1.3.6.0.g96a9b88
Content-Type: text/plain

{"clienttoken":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}
```

### 3. IRKit デバイスを登録します。

取得したクライアントトークンを使って [Hubot brain][brain] に IRKit デバイスを登録します。

```
hubot irkit register device XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX office-amp
```

<p style="padding-top:5em">
<iframe src="http://rcm-fe.amazon-adsystem.com/e/cm?lt1=_blank&bc1=000000&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=atsushnagased-22&o=9&p=8&l=as4&m=amazon&f=ifr&ref=ss_til&asins=B00J5ZDC42" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe> <iframe src="http://rcm-fe.amazon-adsystem.com/e/cm?lt1=_blank&bc1=000000&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=atsushnagased-22&o=9&p=8&l=as4&m=amazon&f=ifr&ref=ss_til&asins=B00H91KK26" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>
</p>

[Hubot]: https://hubot.github.com/
[IRKit]: http://getirkit.com/
[ngs/hubot-irkit]: https://github.com/ngs/hubot-irkit
[ngs/ngsbot]: https://github.com/ngs/ngsbot
[Hubot]: http://hubot.github.com/
[IRKit]: http://getirkit.com/en/
[アフェリエイトリンク]: http://www.amazon.co.jp/gp/product/B00H91KK26/ref=as_li_ss_tl?ie=UTF8&camp=247&creative=7399&creativeASIN=B00H91KK26&linkCode=as2&tag=atsushnagased-22
[オフィシャルドキュメント]: http://getirkit.com/#IRKit-Device-API
[Hubot]: https://hubot.github.com/
[Atsushi Nagase]: http://ngs.io/
[MIT License]: LICENSE
[brain]: https://github.com/github/hubot/blob/master/docs/scripting.md#persistence
