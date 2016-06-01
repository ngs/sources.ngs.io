---
title: "Raspberry Pi で Swift を動かすために試していること"
description: "チャットで Keybase ユーザーに対して暗号化したメッセージを作成する、hubot-keybase を公開しました。"
date: 2016-06-01 22:00
public: false
tags: raspberry pi, swift
alternate: true
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2016-06-01-swifty-gpio/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2016-06-01-swifty-gpio/main.jpg)

TBD


READMORE

## 簡単なLチカ

![](2016-06-01-swifty-gpio/blink.gif)

```swift
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

## 入力値に応じて出力値を変更

![](2016-06-01-swifty-gpio/button.gif)

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

ビルドに失敗しました

```sh
$ git clone git@github.com:slimane-swift/slimane-example.git
$ cd slimane-example
$ make debug

swift build -v -Xlinker -L/usr/lib -Xcc -IPackages/CLibUv-* -Xcc -IPackages/COpenSSL-*
error: unable to invoke subcommand: /home/pi/usr/bin/swift-build (No such file or directory)
Makefile:23: recipe for target 'debug' failed
make: *** [debug] Error 2
```
