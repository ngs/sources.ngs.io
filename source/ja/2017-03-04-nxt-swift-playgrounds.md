---
title: 'Mindstorms NXT Swift Playground Book for iPad #tryswifthack'
description: try! Swift Tokyo 2017 の最終日に行われたハッカソンで Lego Mindstorms NXT を操作するプログラミングを Swift Playgrounds iPad を使って学習できる、Book を開発しました。
date: 2017-03-04 23:59
public: true
tags: swift, hackathon, mindstorms, lego
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2017-03-04-nxt-swift-playgrounds/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2017-03-04-nxt-swift-playgrounds/main.jpg)

2017-03-02, 03, 04 と行われていた [try! Swift Tokyo] の最終日に行われた[ハッカソン]で、一人チームを結成し (?)、[Lego Mindstorms NXT] を操作するプログラミングを [Swift Playgrounds iPad] を使って学習できる、[Book] を開発しました。

- GitHub Repo: [ngs/mindstorms-nxt-playground-book][repo]
- Devpost Page: [Mindstorms NXT Playground Book for iPad](https://devpost.com/software/mindstorms-nxt-playground-book)

READMORE

## How it works

<iframe src="https://player.vimeo.com/video/206693443" width="640" height="360" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
<p><a href="https://vimeo.com/206693443">Mindstorms NXT Swift iPad Playgrounds</a> from <a href="https://vimeo.com/atsnngs">Atsushi Nagase</a> on <a href="https://vimeo.com">Vimeo</a>.</p>

以下の様な Swift コードから、上のデモムービーのような動きを実装します。

```swift
let nxt = NXT(name: "Hello NXT") // initialize robot

nxt.rotate(motor: .a, power: 100, angle: 145.0) // change angle of motor

// define sub routine
let sub = nxt.sub { nxt in
    nxt.forward(length: 100, turn: 0)
    nxt.wait(msec: 500)
    nxt.reverse(length: 100, turn: 0)
    nxt.wait(msec: 500)
}

// call sub routine
sub.call()
```

## Mindstorms NXT

Mindstorms NXT は 2006年に発売された、一昔前の教育用ロボット作成キットです。

現行版の [EV3] のように、[iOS SDK] や [コントローラーアプリ] などは用意されていません。

そのため、以下の様なしくみで、プログラムを NXT に転送しています。

1. Playgrounds で書いた Swift から NXC を書き出す
2. 書き出した NXC のコードをローカルネットワーク上のウェブサーバーに POST する
3. ウェブサーバーで受け取ったソースコードを `nbc` NXC コンパイラコマンドにコンパイルさせる
4. USB で NXT にバイナリを転送し、実行する

以下のセットアップ方法を記載しますので、押し入れに眠っている NXT があったら、引っ張り出してきて、もう一度活躍させてあげてみてください。

## NXC とは

NXC は Lego Mindstorms シリーズのために開発されたC言語ライク (Not eXactly C) なプログラミング言語です。

参照: [NXCを使った LEGO NXT ロボットプログラミング (和訳)](http://tabrain.jp/LEGO/NXC_programing.pdf)

Mindstorms NXT の標準プログラミングソフトウェアは、ブロックをつなぎ合わせて実行内容・条件を組み立てる、グラフィカルなものです。

今回、上記フローの通り、サーバーサイドでコマンドライン実行でコンパイルできるプログラムを扱う必要があったので、この NXC を採用しました。

## 環境セットアップ

NXC を使うためには、NXT 本体にカスタムファームウェアをインストールする必要があります。

[Homebrew] の定義ファイル (Formula) を[用意した][formulae]ので、以下のコマンドを実行するだけで、準備が完了します。

```sh
brew tap ngs/formulae

brew cask install nxt-fantom-driver # USB ドライバ
brew install nexttool nbc # コマンドラインツール

# カスタムファームウェアを解凍してインストール
wget http://bricxcc.sourceforge.net/lms_arm_nbcnxc.zip 
unzip lms_arm_nbcnxc.zip
nexttool -firmware="lms_arm_nbcnxc/lms_arm_nbcnxc_132.rfw"
```

以上で下準備は完了です。Homebrew でインストールした `nbc` コマンドで NXC プログラムを実行してみましょう。

```sh
echo 'task main () { OnFwdSync(OUT_A, 100, 0); Wait(1000); }' > test.nxc
nbc -r test.nxc
```

出力ポート A に接続されているモーターが1秒間回転したと思います。

## ウェブサーバーの起動

このコマンドを HTTP で受信して実行するサーバーを起動します。

サーバーサイドのアプリケーションも Swift で開発しました。

[Tokyo Server Side Swift Meetup] 主催の Takei さん ([@noppoMan]) 作の Go 言語ライクな システム+ネットワーキング/HTTP ライブラリ [Prorsum] を利用しました。

```sh
git clone git@github.com:ngs/mindstorms-nxt-playground-book.git
cd mindstorms-nxt-playground-book/Server
swift package generate-xcodeproj
open NXCBuild.xcodeproj
```

![](2017-03-04-nxt-swift-playgrounds/target.jpg)

Xcode が開くので、`NXCBuild` ターゲットを上のスクリーンショットと同じように選択し、<kbd>&#x2318;+ R</kbd> でサーバーアプリケーションを起動します。

プログラムを HTTP Body にして POST リクエストを送信します。

```sh
curl --data 'task main () { OnFwdSync(OUT_A, 100, 0); Wait(1000); }' \
	http://localhost:3000
```

先ほどとおなじように、一秒間モーターが回ったと思います。

## Playgrounds Book を iPad に転送

![](2017-03-04-nxt-swift-playgrounds/airdrop.jpg)

Playgrounds Book は Air Drop か、iCloud Drive 経由の転送をサポートしています。

[リポジトリ][repo] に含まれている `NXT.playgroundbook` を Air Drop で iPad に転送するか、iCloud Drive にある Playgrounds フォルダにコピーしてください。

![](2017-03-04-nxt-swift-playgrounds/playgrounds.jpg)

iPad で Swift Playgrounds を開くと、NXT というブックが追加されていると思います。

以上でセットアップは完了です。

## TODOs

今回のハッカソンは (遅刻したため) 時間が短かったので、モーターを動かす、サブルーチンを作成する、までしか実装できていません。

今後、以下のような、機能を追加して、より複雑な操作が行えるようにしたいと思います。

- 条件分岐の作成
- センサー入力値の取得
- サブルーチンの引数を指定・利用

## ハッカソン

各地からあつまった Swift 好きのエンジニアの方々が、Swift 縛りで開発を行う、というもので、どのチームの作品もとても魅力的でした。

次回も是非参加したいと思います。

[Balto] を運営されている [Goodpatch] 社さんからスポンサー賞: Baltoの Medium Plan - 1年間分をいただいきました、ありがとうございます。

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">balto(Goodpatch)賞<br>Mindstorms NXT Playground Book for iPad | Devpost<a href="https://t.co/50KxmeHZ6X">https://t.co/50KxmeHZ6X</a><br> <a href="https://twitter.com/hashtag/tryswiftconf?src=hash">#tryswiftconf</a> <a href="https://twitter.com/hashtag/tryswifthack?src=hash">#tryswifthack</a> <a href="https://t.co/FbGvQDpnoG">pic.twitter.com/FbGvQDpnoG</a></p>&mdash; にわタコ (@niwatako) <a href="https://twitter.com/niwatako/status/837997687035191298">March 4, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

[try! Swift Tokyo]: https://www.tryswift.co/tokyo/jp
[ハッカソン]: https://tryswift.devpost.com/
[Lego Mindstorms NXT]: https://ja.wikipedia.org/wiki/Lego_Mindstorms_NXT
[Swift Playgrounds iPad]: http://www.apple.com/jp/swift/playgrounds/
[Book]: https://developer.apple.com/library/content/documentation/Xcode/Conceptual/swift_playgrounds_doc_format/
[EV3]: https://www.lego.com/ja-jp/mindstorms/products/mindstorms-ev3-31313
[iOS SDK]: https://github.com/andiikaa/ev3ios
[コントローラーアプリ]: https://www.lego.com/ja-jp/mindstorms/downloads
[Homebrew]: https://brew.sh/
[formulae]: https://github.com/ngs/homebrew-formulae
[repo]: https://github.com/ngs/mindstorms-nxt-playground-book
[Tokyo Server Side Swift Meetup]: https://tokyo-ss-swift.connpass.com/
[@noppoMan]: https://github.com/noppoMan/
[Prorsum]: https://github.com/noppoMan/Prorsum
[Balto]: https://www.balto.io/ja/
[Goodpatch]: http://goodpatch.com/jp