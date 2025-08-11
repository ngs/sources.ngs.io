---
title: Apply UIAppearance immediately on the screen
description: How to apply appearance changes made with UIAppearance's proxy method  immediately
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

I was looking for how to apply changes made with UIAppearance's proxy method immediately.

I found a solution in a library [UISS], that handles Stylesheets written with JSON format.

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


This code detaches all subviews of `window` and attach them again.

I also tried `setNeedsDisplay` and `setNeedsLayout`, but didn't work. So I adapted this hack.

Here is Swift version.

<%= partial 'partials/2014-10-26-refresh-ui-appearance/refreshViews.swift' %>

[UISS]: https://github.com/robertwijas/UISS
