---
title: ActionScript 2 でデバイスフォントを90度回転
description: ActionScript 2 でデバイスフォントを90度回転
date: 2007-08-10 00:00
public: true
tags: flash, actionscript, font
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

READMORE

```java
import flash.display.*;
import flash.geom.*;
var clip:MovieClip;
var clip2:MovieClip = createEmptyMovieClip("clip2", 0);
clip2._x = clip._x+100;
clip2._y = clip._y;
var bmp:BitmapData = new BitmapData(clip._width, clip._height);
clip2.attachBitmap(bmp,1);
bmp.draw(clip);
clip2._width = clip._width;
clip2._height = clip._height;
clip2._rotation = 90;
```
