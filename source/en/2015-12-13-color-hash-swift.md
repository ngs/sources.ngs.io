---
title: "Generate NSColor / UIColor based on Swift String"
description: "I've published a Swift library ColorHash, that generates UIColor and NSColor based on given string."
date: 2015-12-13 17:00
public: true
tags: color, swift, coccoa, ios
alternate: true
ogp:
  og:
    image:
      '': https://ngs.io/images/2015-12-13-color-hash-swift/og.png
      type: image/png
      width: 992
      height: 525
---

![](images/2015-12-13-color-hash-swift/screen.gif)

I've published a Swift library [ColorHash], that generates `UIColor` and `NSColor` based on given string.

**[ngs/color-hash.swift]**

```swift
import ColorHash

let str = "こんにちは、世界"
let saturation = CGFloat(0.30)
let lightness = CGFloat(0.70)

ColorHash(str, [saturation], [lightness]).color
```

This is a Swift port of a JavaScript library [Color Hash](https://github.com/zenozeng/color-hash).

READMORE

Install
-------

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
