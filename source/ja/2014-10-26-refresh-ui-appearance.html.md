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

![](2014-10-26-refresh-ui-appearance/screen.gif)

UIAppearance の proxy メソッドから見た目を変更して、即時全画面に適用する方法を調べていて、[UISS] という iOS で JSON 形式の Stylesheet を扱うライブラリにその答えがあったので、メモです。

READMORE

[UISS#refreshViews]

```objc
- (void)refreshViews {
    [[NSNotificationCenter defaultCenter] postNotificationName:UISSWillRefreshViewsNotification object:self];

    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:UISSDidRefreshViewsNotification object:self];
}
```

[UISS#refreshViews]: https://github.com/robertwijas/UISS/blob/8f2412b2dda19aa945c201b65dd7b777441c38ab/Project/UISS/UISS.m#L177


`window` の子ビューを全て剥がして貼り直しています。

`setNeedsDisplay`, `setNeedsLayout` も試してみましたが、動かなかったので、こちらを採用します。

Swift で書くとこんな感じです。

<%= partial 'partials/2014-10-26-refresh-ui-appearance/refreshViews.swift' %>

[UISS]: https://github.com/robertwijas/UISS
