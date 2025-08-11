---
title: SWFAddress の Safari3での問題
description: SWFAddress の Safari3での問題
date: 2007-09-12 00:00
public: true
tags: actionscript, javascript, swfaddress, safari
---

Safari 3 Betaで、`SWFAddress.setValue('hoge')` を実行した際、隠し form `{ action = #hoge, method = get }` をsubmitして、履歴を追加するため、URLに `?` が付いていない場合、ファイル名の最後に `?` を追加され、HTML はリフレッシュされ、SWF は振り出しに戻ります。

READMORE


## 再現したバージョン

`javascript:alert(asual.util.Browser.version)`

| ブラウザ | 結果 | 再現 | navigator.userAgent |
| :-----: | :---: | :---: | :------------: |
| Safari3.0.3 | 522.12 | ● | Mozilla/5.0 (Macintosh; U; Intel Mac OS X; ja-jp)<br>AppleWebKit/522.11.1 (KHTML, like Gecko)<br>Version/3.0.3<br>Safari/522.12.1 |
| Shiira2.2 | 125 | ● | Mozilla/5.0 (Macintosh; U; Intel Mac OS X; ja-jp)<br>AppleWebKit/522.11.1 (KHTML, like Gecko)<br>Shiira<br>Safari/125 |
| Safari3.0.3(Windows) | 522.15.5 | ● | Mozilla/5.0 (Windows; U; Windows NT 5.1; ja)<br> AppleWebKit/522.15.5 (KHTML, like Gecko)<br>Version/3.0.3<br>Safari/522.15.5 |


参照: [Safariのバージョンを判別する](http://www.openspc2.org/reibun/javascript/kihon/015/)

----
<s>それを回避するために、以下の記述をします。</s>

以下はそれを回避するための方法のドラフトです。

```js
var l = document.location.toString();
var b = asual.util.Browser;

if(b.safari&&l.indexOf("?")==-1)
  document.location.href = l.indexOf("#")>=0 ? l.split("#").join("?#") : (l + "?");

else {
  var so = new SWFObject("hoge.swf", "hoge", "100%", "100%", 8, "#FFFFFF");
  // ...
  so.write("flashcontent");
}
```

hoge.html#permalinkにアクセスした際、SWFを表示せず、hoge.html?#permalinkに強制的に遷移させます。

## SWFAddress について

### 参考リンク

* [SWFAddress](http://www.asual.com/swfaddress/)
* [あるＳＥのつぶやき: SWFAddress - Flashでパーマリンクを実現するライブラリ](http://fnya.cocolog-nifty.com/blog/2007/05/swfaddress_flas_3299.html)
* [trick7.com blog: SWFAddress](http://www.trick7.com/blog/2006/10/27-143606.php)

### 使い方: ActionScript 2

```java
import SWFAddress;
class Hoge extends MovieClip {
  static var ins:Hoge;
  public var btn1:MovieClip, btn2:MovieClip, btn3:MovieClip, btn4:MovieClip;

  public function Hoge():Void {
    ins = this;
    SWFAddress.onChange = function() {
      var i:String = SWFAddress.getPath();
      Hoge.ins._setContent(i);
    }
    onLoad = init;
  }

  private function init():Void {
    var ar:Array = ["content1", "content2", "content3", "content4"];
    var bt:Array = [btn1, btn2, btn3, btn4];
    for(var i:String in bt) {
      bt[i].contentName = ar[i];
      bt[i].onRelease = function() { Hoge.ins.setContent(this.contentName); }
    }
  }

  public function setContent(i:String):Void {
     SWFAddress.setValue(i);
  }

  public function _setContent(i:String):Void {
     SWFAddress.setTitle(i);
    //do something
  }

}
```
