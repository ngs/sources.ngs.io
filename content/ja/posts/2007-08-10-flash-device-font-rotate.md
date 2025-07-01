---
title: "ActionScript 2 でデバイスフォントを90度回転"
description: "ActionScript 2 でデバイスフォントを90度回転"
date: 2007-08-10T00:00:00+09:00
public: true
tags: ["flash", "actionscript", "font"]
alternate: false
ogp:
  og:
    image:
      '': 2007-08-10-flash-device-font-rotate/preview.png
      type: image/png
      width: 212
      height: 150
---

![](2007-08-10-flash-device-font-rotate/preview.png)

デバイスフォントは `_rotation` を設定して回転させると、見えなくなってしまうので、ビットマップとして複製してから回転をかける。

<!--more-->

{{< partial "2007-08-10-flash-device-font-rotate/rotate.as.html.md" >}}
