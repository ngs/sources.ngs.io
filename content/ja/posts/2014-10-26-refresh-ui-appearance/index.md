---
title: UIAppearance 変更時、リアルタイムに画面反映する
description: UIAppearance の proxy メソッドから見た目を変更して、即時全画面に適用する方法
date: 2014-10-26 21:30
public: true
tags: ios, uiappearance, objective-c, swift, uikit
alternate: true
ogp:
  og:
    image:
      '': 2014-10-26-refresh-ui-appearance/og.png
      type: image/png
      width: 500
      height: 500
---

![](screen.gif)

UIAppearance の proxy メソッドから見た目を変更して、即時全画面に適用する方法を調べていて、[UISS] という iOS で JSON 形式の Stylesheet を扱うライブラリにその答えがあったので、メモです。

READMORE



`window` の子ビューを全て剥がして貼り直しています。

`setNeedsDisplay`, `setNeedsLayout` も試してみましたが、動かなかったので、こちらを採用します。

Swift で書くとこんな感じです。



[UISS]: https://github.com/robertwijas/UISS
