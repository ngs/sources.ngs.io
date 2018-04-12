---
title: "Swift の文字列から NSColor / UIColor を生成する"
description: "Swift の文字列から NSColor / UIColor を生成するライブラリ ColorHash を公開しました。"
date: 2015-12-13 17:00
public: true
tags: color, swift, coccoa, ios
alternate: true
ogp:
  og:
    image:
      '': https://ja.ngs.io/images/2015-12-13-color-hash-swift/og.png
      type: image/png
      width: 992
      height: 525
---

![](images/2015-12-13-color-hash-swift/screen.gif)

Swift の文字列から `NSColor` / `UIColor` を生成するライブラリ [ColorHash] を公開しました。

**[ngs/color-hash.swift]**

```swift
import ColorHash

let str = "こんにちは、世界"
let saturation = CGFloat(0.30)
let lightness = CGFloat(0.70)

ColorHash(str, [saturation], [lightness]).color
```

このライブラリは JavaScript ライブラリ [Color Hash](https://github.com/zenozeng/color-hash) を参考に開発しました。

READMORE

インストール
----------

### CocoaPods

```rb
pod 'ColorHash'
```

### Carthage

```rb
github 'ngs/color-hash.swift'
```

[ngs/color-hash.swift]: https://github.com/ngs/color-hash.swift
[ColorHash]: https://github.com/ngs/color-hash.swift
