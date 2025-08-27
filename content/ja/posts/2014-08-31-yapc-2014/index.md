---
title: 'YAPC::Asia Tokyo 2014 所感 #yapcasia'
description: 2014.08.28-30 に開催された YAPC::Asia Tokyo 2014 に参加しました。
date: 2014-08-31 14:00
public: true
tags: yapc, 所感, conference
alternate: false
ogp:
  og:
    image:
      '': http://yapcasia.org/2014/static/images/logo_l.png
      type: image/png
      width: 635
      height: 220
---

2014.08.28-30 に開催された [YAPC::Asia Tokyo 2014] に参加しました。

[2009年]から参加しているので、6回目の参加でしたが、初めて感想を書きます。

話聞いてるか話しているか酔っていたので、写真はないです。

READMORE

Day 0
-----

### [欲しいものは作ればいい！ 〜Webアプリ10連発〜]

今年はじめて前夜祭から参加しました。

ビールのみながら個人でサービスを運営されている皆さんのお話を聞いていました。

飽きてメンテナンスやめても、怒られない様に、予め [OSS 化][open-wripe] (機能要望あったら Pull-req くれ) & 外部連携 (Dropbox, Evenote) しているという [wri.pe] の [@masuidrive] 氏の話は自分も実践したいと思いました。

(彼らと並べて話すのはおこがましいですが、自分も放置して腐っているアプリが数件あるので)

Day 1
-----

### [Perl meets Real World 〜ハードウェアと恋に落ちるPerlの使い方〜]

前半は、自分には馴染みのある [Raspberry Pi] や [Arduino] の説明をされていました。

後半、サーボでネギをふるデモを行おうとされていました。 ([参照][step3])

セッション中では動くものが見れませんでしたが、懇親会で実際に動く所を見せていただくことができ、かなり機敏に反応していました。

これをみて、自分もウェブページと連動する何かを日曜大工で作ってみようと思いました。

かつて、Nゲージのパワーユニット自作していたので、その残骸を使って Web 画面からコントロールできるようにするなどやってみたいと思います。

### [いろんな言語を適材適所で使おう]

http://blog.kentarok.org/entry/2014/08/31/113609

ペパボの CTO の[あんちぽくん氏]が、表題の内容を分かりやすく話されていました。

自分も人生で初めて (まだ一年目だけど) 長く一つの組織に属するみたいなことを経験していて、**継続的に価値を提供し続けるための技術選択はどのようにあり得るのか** みたいな氏のテーマにあげている問題に取り組む機会を得ているので、とても興味深い内容でした。

<s>SOA</s> microservice 化やるぜ、みたいな話を今までも何度かしていて、"何で？" みたいな質問をされたときに、うまく説明できていなかったので、ちょっと頭の中が整理された気がします。

### [コマンドラインツールについて語るときに僕の語ること]

golang でツールを開発されている [Taichi Nakashima] 氏のお話。氏の考える良い CLI ツールとはというお話を哲学とともに、ツールで簡単に実践できますよ、というのをデモされていました。

元々[氏のブログ][Taichi Nakashima]を読んで、実践しようと思っていたので、改めてモチベーションが上がりました。まずは README から。

参照: [tcnksm/cli-init]

Day 2
-----

午後から参加し、しばらく人と話していました。

### [キーノート]

面白法人から独立されて会社を立ちあげられた [typester] 氏の Emotional talk。

20代の人に向けて **20代の経験が今後のベースになる** とお話されていて、自分にも心あたりがあり、勝手に20代の頃の思い出に浸っていました。

40代になったら、30代の経験もベースになると思うので、これからも日々精進しようと思った次第です。

その他
-----

- Peatix のメールから、どうしてもベストトーク投票用の番号を見つけることができませんでした、個人スポンサーだから？
- 上記のセッションのスピーカーの方に投票するつもりでした。

まとめ
-----

ということで、とても今年も素晴らしいカンファレンスで沢山モチベーションを貰いました。お酒も沢山呑みました。しばらく休肝したいと思います。来年も開催されますように。

[YAPC::Asia Tokyo 2014]: http://yapcasia.org/2014/
[2009年]: http://conferences.yapcasia.org/ya2009/
[wri.pe]: https://wri.pe/
[@masuidrive]: https://github.com/masuidrive
[open-wripe]: https://github.com/masuidrive/open-wripe
[欲しいものは作ればいい！ 〜Webアプリ10連発〜]: http://yapcasia.org/2014/talk/show/bc6052f4-0c8b-11e4-aec0-ad686aeab6a4
[Perl meets Real World 〜ハードウェアと恋に落ちるPerlの使い方〜]: http://yapcasia.org/2014/talk/show/103a434e-ec02-11e3-bd6d-c7a06aeab6a4
[Raspberry Pi]: http://www.raspberrypi.org/
[Arduino]: http://arduino.cc/
[step3]: https://speakerdeck.com/mackee/perl-meets-real-world?slide=70
[いろんな言語を適材適所で使おう]: http://yapcasia.org/2014/talk/show/ce831248-ebb4-11e3-bd6d-c7a06aeab6a4
[あんちぽくん氏]: https://twitter.com/kentaro
[コマンドラインツールについて語るときに僕の語ること]: http://yapcasia.org/2014/talk/show/b49cc53a-027b-11e4-9357-07b16aeab6a4
[Taichi Nakashima]: http://deeeet.com/writing/
[tcnksm/cli-init]: https://github.com/tcnksm/cli-init
[キーノート]: http://yapcasia.org/2014/talk/show/4c1b9652-0c86-11e4-aec0-ad686aeab6a4
[typester]: http://unknownplace.org/
[氏の会社]: http://makeitreal.jp/
