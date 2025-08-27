---
title: "Keybase ユーザーに対して PGP 暗号化したメッセージをチャットで作成する"
description: "チャットで Keybase ユーザーに対して暗号化したメッセージを作成する、hubot-keybase を公開しました。"
date: 2016-05-14 07:45
public: true
tags: hubot, keybase, pgp, encryption
alternate: true
ogp:
  og:
    image:
      '': 2016-05-14-hubot-keybase/screen.png
      type: image/png
      width: 1358
      height: 737
---

![](screen.png)

[Keybase] に招待して頂き、使い始めたので、暗号化メッセージを CLI やウェブ画面なしで、携帯からでも作成できやしないかと考え、久しぶりに [Hubot] スクリプトをこしらえてみました。

ref: **[ngs/hubot-keybase][hubot-keybase] on GitHub**

READMORE

## 使い方

こんな感じでチャットでメッセージを送ると

```sh
hubot keybase encrypt:ngs Hi there!
#                     ^ Keybase username!
```

Hubot が 指定したユーザーの公開鍵を使って暗号化したメッセージを返してきます。

```
-----BEGIN PGP MESSAGE-----
Version: OpenPGP.js v2.3.0
Comment: http://openpgpjs.org

wcBMA2GjYRB9O5DgA...(snip)
-----END PGP MESSAGE-----
```

## インストール

1\. `hubot-keybase` を npm の依存ライブラリに追加します。

```bash
npm install --save hubot-keybase
```

2\. `external-scripts.json` に `hubot-keybase` を追加します。

```json
["hubot-keybase"]
```

## お問い合わせなど

もしバグやリクエストがありましたら、気軽に GitHub Issue を登録してください。プルリクも歓迎です！

https://github.com/ngs/hubot-keybase/issues

楽しい暗号化ライフを！

[Keybase]: https://keybase.io/
[hubot-keybase]: https://github.com/ngs/hubot-keybase
[Hubot]: https://hubot.github.com/
