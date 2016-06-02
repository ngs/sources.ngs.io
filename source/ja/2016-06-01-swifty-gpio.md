---
title: "Raspberry Pi で Swift を動かす"
description: "Raspberry Pi で Swift を動かして、GPIO を操る実験について"
date: 2016-06-01 23:40
public: true
tags: raspberry pi, swift
alternate: false
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2016-06-01-swifty-gpio/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2016-06-01-swifty-gpio/main.jpg)

少し前に、[SwiftyGPIO] というライブラリを発見し、ついに Swift が電子工作に使えるようになったのか、と試してみたいと思い、着手していました。

ただ、Apple が公式に [Swift.org] で配布している Snapshot バイナリは、x86_64 環境でビルドされたもので、ARM CPU を使っている Raspberry Pi では実行することができません。

[SwiftyGPIO] の作者である、[uraimo 氏のブログ記事] に記載されている方法でさくっとサンプルを動かすところまでは、とても簡単に実践できます。

READMORE

## 環境設定

使用機材は [Raspberry Pi Type B]、OS は [Raspbian Jessie 2016-05-27] です。

`clang` をインストールし、バイナリーをダウンロードし、解答します。前述のブログ記事からのコピペです。

```sh
$ sudo apt-get update
$ sudo apt-get install clang

$ wget https://www.dropbox.com/s/smk3ek5lfa8ae09/swift-2016-02-15.tar.gz
$ tar xzf swift-2016-02-15.tar.gz
```

`Hello world` で動作確認します。

```sh
$ export PATH=$HOME/usr/bin:$PATH
$ which swiftc
　
/home/pi/usr/bin/swiftc
　
$ echo 'print("Hello world")' > helloworld.swift
$ swiftc helloworld.swift
$ ./helloworld
　
Hello world
```

## 簡単なLチカ

![](2016-06-01-swifty-gpio/blink.gif)

[README の Example] コードのボードと Pin の値だけ修正すると、すんなりLチカができます。

```swift
// main.swift
import Glibc

let gpios = SwiftyGPIO.getGPIOsForBoard(.RaspberryPiRev2)
var gp = gpios[.P9]!
gp.direction = .OUT
gp.value = 1

repeat{
     gp.value = (gp.value == 0) ? 1 : 0
     usleep(150*1000)
}while(true)
```

```sh
$ wget https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SwiftyGPIO.swift
$ swiftc main.swift SwiftyGPIO.swift
$ sudo ./main
```

`SwiftyGPIO.getGPIOsForBoard(board: SupportedBoard)` で指定可能なボードは [SwiftyGPIO.swift] に入っている Enum で定義されています。

```swift
public enum SupportedBoard {
    case RaspberryPiRev1   // Pi A,B Revision 1
    case RaspberryPiRev2   // Pi A,B Revision 2
    case RaspberryPiPlusZero // Pi A+,B+,Zero with 40 pin header
    case RaspberryPi2 // Pi 2 with 40 pin header
    case CHIP
    case BeagleBoneBlack
}
```

なんと、[Raspberry Pi 3] がありません。 _Cortex-A53 ARMv8 64bit_ で動く Swift のバイナリがないので、動作確認ができないのでしょうか。

## 入力値に応じて出力値を変更

![](2016-06-01-swifty-gpio/button.gif)

[Usage] に記載されているとおり、入力モード Pin の値を変更をクロージャーでハンドリングできます。

`GPIO` クラスのインスタンスには、以下の関数が用意されており、引数でクロージャーを渡すことで、値の変更の通知を受け取ります。

- `onRaising` `0` -> `1` に値が変わった
- `onFalling` `1` -> `0` に値が変わった
- `onChange` 何かしら値が変わった



```swift
import Glibc

let gpios = SwiftyGPIO.getGPIOsForBoard(.RaspberryPiRev2)
var led = gpios[.P9]!
led.direction = .OUT
led.value = 0

var button = gpios[.P2]!
button.direction = .IN
button.value = 1

button.onChange { button in
     led.value = button.value == 1 ? 0 : 1
     print(button.value)
}

while(true) {}
```

## Slimane と連携

![](2014-08-02-watering-pi/1.jpg)

以上の様に、簡単に GPIO の機能が Swift であつかえます。Raspberry Pi 単体で完結する仕組みを作るには、実用に足るライブラリだと思います。

ここまで実践すると、Internet of Things な、例えば WebSocket のイベントを受け取ると水やりをする、みたいな活用を行いたいと思い始めます。

参考: [Raspberry Pi と Hubot で観葉植物の水やりを自動化する](/2014/08/02/watering-pi/)

OSS Swift に対応した WebSocket クライアントが見つけられなかったので、手始めに、[Tokyo Server-Side Swift Meetup] の共同主催者、[@noppoman] 氏作の Web フレームワーク、[Slimane] を使って、以下の様に HTTP で `PUT` リクエストがあれば、LED と On / Off するサンプルを書いて、ビルドしてみました。

```
$ curl -XPUT my-raspberry-pi.local:3000/toggle
```

Package.swift

```swift
import PackageDescription

let package = Package(
      name: "SlimaneGPIO",
      dependencies: [
          .Package(url: "https://github.com/noppoMan/Slimane.git", majorVersion: 0, minor: 4),
      ]
)
```

Sources/main.swift

```swift
import Slimane
import Glibc

let app = Slimane()

let gpios = SwiftyGPIO.getGPIOsForBoard(.RaspberryPiRev2)
var gp = gpios[.P9]!
gp.direction = .OUT
gp.value = 0

app.put("/toggle") { req, responder in
    responder {
      let wasOn = gp.value == 1
      gp.value = wasOn ? 0 : 1
      Response(body: "Tuned \(wasOn ? "off" : "on")!")
    }
}

try! app.listen()
```

こちらを `swift build` コマンドでビルドしようとしましたが、`build` サブコマンドが存在しないので、失敗しました。

```sh
$ swift build
error: unable to invoke subcommand: /home/pi/usr/bin/swift-build (No such file or directory)
```

ダウンロードしてきた、Prebuilt バイナリには、[swift-build] が含まれておらず、Swift Package Manager の資産は流用できないようです。

Swift on ARM について、深く研究を行われている、[@iachievedit] 氏が提供されている [Jenkins] でできた成果物 (Artifacts) のバイナリも [swift-build] を含んでいませんでした。

参照

- [Latest Artifacts of Swift-3.0-ARM-Incremental](http://swift-arm.ddns.net/job/Swift-3.0-ARM-Incremental/lastSuccessfulBuild/artifact/)
- [Swift for ARM Systems](http://dev.iachieved.it/iachievedit/swift-for-arm-systems/)
- [Swift ARM on Slack](https://swift-arm.slack.com/)

## TODOs

これから、Raspberry Pi 遊びにも Swift を活用すべく、引き続き研究を続けていき、[Tokyo Server-Side Swift Meetup] などで経過発表を続けていけたらな、と思います。

- 自前で全部入りの Swift バイナリをビルドする
- クロスコンパイルがうまくできないか OS X 環境でもためしてみる

あたり、試してみたいと思っています。どうぞよろしくお願いいたします。

<script> window.setupAmazonWidget() </script>
<script src='https://wms-fe.amazon-adsystem.com/20070822/JP/js/AmazonWidgets.js'></script>

[SwiftyGPIO]: https://github.com/uraimo/SwiftyGPIO
[Swift.org]: https://swift.org/
[uraimo 氏のブログ記事]: https://www.uraimo.com/2016/03/10/swift-3-available-on-armv6-raspberry-1-zero/
[Raspberry Pi Type B]: http://www.amazon.co.jp/gp/product/B00CBWMXVE/ref=as_li_ss_tl?ie=UTF8&camp=247&creative=7399&creativeASIN=B00CBWMXVE&linkCode=as2&tag=ngsio-22
[Raspbian Jessie 2016-05-27]: https://www.raspberrypi.org/downloads/raspbian/
[SwiftyGPIO.swift]: https://github.com/uraimo/SwiftyGPIO/blob/master/Sources/SwiftyGPIO.swift
[Raspberry Pi 3]: http://www.amazon.co.jp/gp/product/B01CSFZ4JG/ref=as_li_ss_tl?ie=UTF8&camp=247&creative=7399&creativeASIN=B01CSFZ4JG&linkCode=as2&tag=ngsio-22
[README の Example]: https://github.com/uraimo/SwiftyGPIO#examples
[Usage]: https://github.com/uraimo/SwiftyGPIO#usage
[@noppoman]: https://github.com/noppoman
[Slimane]: https://github.com/noppoMan/Slimane
[swift-build]: https://github.com/apple/swift-llbuild
[swift-arm]: https://swift-arm.slack.com
[@iachievedit]: http://dev.iachieved.it/iachievedit/
[Jenkins]: http://swift-arm.ddns.net/
[Tokyo Server-Side Swift Meetup]: http://tokyo-ss-swift.connpass.com/
