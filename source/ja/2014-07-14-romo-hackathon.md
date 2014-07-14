---
title: '#Romoハッカソン に参加してきた'
description: 2014/07/13 目黒の Hub Tokyo で開催された Romo ハッカソンに参加してきました。
date: 2014-07-14 23:50
public: true
tags: romo, robot, hackathon, ios, hubot, apn
alternate: false
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2014-07-14-romo-hackathon/romos.jpg
      type: image/jpg
      width: 992
      height: 525
---

![](2014-07-14-romo-hackathon/romos.jpg)

07/13 目黒の [Hub Tokyo] (めっちゃ近所) で開催された [Romo ハッカソン] に参加してきました。

READMORE

## 初代 Romo の思い出

Romo は [Kickstarter] で 2011年に発売された、iPhone とつなげて動かす、ラジコンのおもちゃです。

初代の Romo は、ミニジャックで iPhone と接続し、そこから出力される音声から、左右のキャタピラを操作するシンプルもので、SDK も公開されていて、自分も1台所有しています。

かつて [公式 GitHub Organization] に公開されていた SDK は 自分のアカウントに Fork しました。 [ngs/Romo-SDK]

## 新型 Romo

今回、太っ腹にも配布していただいたものは、初代とは違い Lightning コネクタで iPhone5/5S と接続する形式に変わり、LED On/Off、マウントの傾きも変わる、完成度の高いおもちゃになっていました。

現在は [公式 GitHub Organization] には、SDK のコードが公開されておらず、作りかけの [RMVision] というライブラリが公開されています。(後述)

SDK は公式サイトからバイナリでダウンロードします。 [Romotive Developers]

詳しくは、チュートリアルが gihyo.jp で連載されているので、参考にしてみてください。 [Romo×iPhoneで楽しむロボット体験]

## 何を作ったか

**iPhone と Romo で目覚ましアプリを作る** というお題だったので、久々の iOS 開発で、Swift とかさわっちゃうぞー、と意気込んでいました。

が、SDK に付属している、サンプルコードを動かしただけで十分うるさく、目覚ましとしては機能したので、結局 iOS 側は、それをちょっとカスタマイズしただけのものになりました。 > [diff]

普通の時計アプリは、過去に嫌という程作ったので、時間の概念のない、**同僚に起こしてもらう** 目覚ましアプリという体で、おなじみ [Hubot] 連携を行い、Push 通知で操作できる様にしました。

[実装コード]

```
同僚   > hubot ngsromo wakeup
Hubot > Waking up ngsromo
```

ついでに、[hubot-yo] のコードをカスタマイズして、[YO] で起こしてくれる様にもしました。

## RMVision

最初、[RMVision] に輝度センサーがあるということで、脳内企画では、外が明るくなったら、暴れ出す様なものを作ろうと思っていたのですが、以下の様に、依存プロジェクト `RMShared.xcodeproj` の欠損により、ビルドできませんでした。

![](2014-07-14-romo-hackathon/rmshared.png)

無事音声するといいですね。

## Hackathon の感想

みなさん、凄腕ハッカー揃いで、発表を聞いていて楽しかったです。

ほとんどの人がロボットとは関係ない仕事だと思うので、まったりと開発を楽しんでいる感じの、良いイベントでした。

勝手に ngs 賞は Romo を魚に見立てて遊ぶ釣りゲームでした。(どこかに映像なりアップされていないかな。。)


[Hub Tokyo]: http://hubtokyo.com/
[Romo ハッカソン]: http://everevo.com/event/13478
[Kickstarter]: https://www.kickstarter.com/projects/peterseid/romo-the-smartphone-robot
[公式 GitHub Organization]: https://github.com/romotive
[RMVision]: https://github.com/Romotive/RMVision
[ngs/Romo-SDK]: https://github.com/ngs/Romo-SDK
[Romotive Developers]: http://www.romotive.com/developers/
[diff]: https://github.com/ngs/20140713-romo-hackathon/commit/35f535a186b37a7c638e23d92b25f48a329be9fa
[Hubot]: https://hubot.github.com/
[hubot-yo]: https://github.com/sakatam/hubot-yo
[YO]: http://www.justyo.co/
[実装コード]: https://gist.github.com/ngs/d792d02c8c7e5bf952e1
[Romo×iPhoneで楽しむロボット体験]: http://gihyo.jp/dev/serial/01/romo
