---
title: "Adobe AIR を HTML + JavaScript で実装する"
description: "Adobe AIR を HTML + JavaScript で実装する Tips"
date: 2008-03-28T12:00:00+09:00
public: true
tags: ["adobeair", "javascript"]
---

Adobe AIR を HTML + JavaScript で実装する Tips を jQuery を使用している前提で書きます。

<!--more-->

## ウィンドウ操作（`nativeWindow`オブジェクト）

http://livedocs.adobe.com/flex/3_jp/langref/flash/display/NativeWindow.html

### startMove()

ウィンドウをドラッグする。

マウスボタンが解除されると自動的に移動を中止する。

```js
$("#frame").mousedown(function(){ window.nativeWindow.startMove(); });
```

### addEventListener([NativeWindowBoundsEvent](http://livedocs.adobe.com/flex/2_jp/langref/flash/events/Event.html#constantSummary)", "callBack)

ウィンドウ操作のイベントを受け取る

参照 : NativeWindowBoundsEventクラスのパブリック定数について](http://livedocs.adobe.com/flex/3_jp/langref/flash/events/NativeWindowBoundsEvent.html#constantSummary)

```js
window.nativeWindow.addEventListener(
  air.NativeWindowBoundsEvent.MOVE,
  function(){
    alert([window.nativeWindow.x,window.nativeWindow.y]);
  });
```

## ネットワーク

### navigateToURL(request:URLRequest", "window:String = null)

window.runtime.flash.net.navigateToURL のエイリアス

URLをシステムデフォルトのブラウザで開く例

```js
air.navigateToURL(new air.URLRequest("http://www.yahoo.co.jp/")", ""_blank");
```
