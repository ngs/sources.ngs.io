---
title: 'macOS 環境のための CircleCI Orbs を公開しました'
description: 'CircleCI での iOS アプリの開発に利用していた、設定を汎用化し、CircleCI Orbs Registry に公開した、Orbs について'
date: 2018-12-25 00:00
public: true
tags: circleci, orb, ci2go, macos, xcode, fastlane, ci
alternate: false
ogp:
  og:
    image:
      '': 2018-12-25-circleci-orbs/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2018-12-25-circleci-orbs/main.jpg)

この記事 [CircleCI Advent Calendar 2018] の25日目の投稿です。

## TL;DR

CircleCI での iOS アプリの開発に利用していた、設定を汎用化し、[CircleCI Orbs Registry] に公開した、以下の Orbs の使い方と、開発のモチベーションについて記載します。

- [ngs/carthage]
- [ngs/fastlane]
- [ngs/swiftlint]
- [ngs/danger]

これらの Orbs のソースコードは、全て以下のリポジトリで管理しています。

[ngs/circleci-orbs on GitHub](https://github.com/ngs/circleci-orbs)

__READMORE__

## モチベーション

2014年より、オープンソースで開発している iPhone, iPad, Apple Watch 向け CircleCI クライアント CI2Go は、もちろん、CircleCI の macOS 環境を利用して 継続的インテグレーション・デリバリー を行なっています。

- [ngs/ci2go on CircleCI](https://circleci.com/gh/ngs/ci2go)
- [ngs/ci2go on GitHub](https://github.com/ngs/ci2go)
- [App Store](https://itunes.apple.com/app/id940028427?mt=8)

バージョン 1 の時代は、CircleCI 1.0 でのビルド環境を使い、[fastlane] などの周辺ツールも、今ほど機能が豊富ではなかったので、色々試行錯誤してきました。

ref: [iOS アプリの継続ビルドを CircleCI に変更した](/2015/03/24/circleci-ios/)

2017 年 に CircleCI 2.0 が発表され、同年11月 [macOS サポート]も開始しました。

しばらく iOS 開発から離れた仕事をしていたので、指を加えて見ているだけでしたが、今年、しばらくメンテナンスが止まっていた CI2Go の CocoaPods での依存解決, Realm (オフラインサポート) を廃止し、バージョン 2.0 として Swift 4, Carthage を使い再構築を行いました。

ref: [CI2Go バージョン 2](/2018/07/02/ci2go-v2/)

その当時の設定ファイルが、以下のようなものです。

[.circleci/config.yml@v2.0.0](https://github.com/ngs/ci2go/blob/v2.0.0/.circleci/config.yml)

Workflows を採用することで、ビルドプロセスの見通しがよくなり、fastlane の進化により、以前のような、証明書関連や、依存解決に関わるヤクの毛刈りはほとんどなくなりました。

以降、いくつかのプロジェクトで、この CI2Go の CircleCI 設定をコピーして、他のプロジェクトで活用してきました。

今年、11月に [CircleCI Orbs が、一般に利用可能になった](https://circleci.com/blog/announcing-orbs-technology-partner-program/)ため、これらの設定を汎用化し、[CircleCI Orbs Registry] に公開しました。

- [ngs/carthage]
- [ngs/fastlane]
- [ngs/swiftlint]
- [ngs/danger]

## 利用方法

`ngs` の名前空間で公開しているこれらの Orb は認証を得ていない、サードパーティですので、CircleCI 画面左側ナビゲーション > _Settings_ > _Security_ (`https://circleci.com/gh/organizations/{orgname}/settings#security`)<br>
より、一つ目のラジオボタン `Yes, allow all members of my organization to publish dev orbs...` を選択してください。

また、プロジェクト設定 > _Build Settings_ > _Advanced Settings_ の _Enable build processing (preview)_ `https://circleci.com/gh/{orgname}/{repo}/edit#advanced-settings` がオフになっている場合は、そちらも On にしてください。

### Carthage

[ngs/carthage]

Carthage の依存解決を行います。

デプロイメントターゲットを指定することにより、参照先とプロジェクトのデプロイメントターゲットの乖離による App Store Connect アップロード時のエラーを防ぎます。

ref: [Xcode 10 GM - Invalid Binary Architecture when submitting to App Store Connect?](https://stackoverflow.com/a/52315766)

```yml
version: 2.1

orbs:
  carthage: ngs/carthage@0.0.2

jobs:
  main:
    macos:
      xcode: 10.1.0
    steps:
      - carthage/setup:
          platforms: iOS,watchOS
          watch_os: '5.0'
          iphone_os: '11.0'
          cache_key_prefix: 2-carthage-
      - ...

workflows:
  main:
    jobs:
      - main
```

### fastlane

[ngs/fastlane]

[fastlane] コマンドと、依存する RubyGems の解決を行う Bundler コマンドを実行する、コマンド、実行に求められる環境変数が備わった Executor、単体の lane を実行するジョブを提供します。

```yaml
version: 2.1

orbs:
  fastlane: ngs/fastlane@0.0.2

jobs:
  build_and_deploy:
    executor: fastlane/macos
    steps:
      - fastlane/bundle-install
      - fastlane/lane:
          command: run match --readonly --type adhoc
      - fastlane/lane:
          command: my_app_build
      - fastlane/lane:
          command: my_app_deploy
      - ...

workflows:
  build_and_deploy:
    jobs:
      - build_and_deploy
      - fastlane/lane:
          command: my_single_lane
```

### SwiftLint, Danger

[Danger] と [SwiftLint] を実行するジョブを提供します。

```yaml
version: 2.1

orbs:
  swiftlint: ngs/swiftlint@0.0.1
  danger: ngs/danger@0.0.1

workflows:
  build_and_deploy:
    jobs:
      - swiftlint/run
      - danger/run
```

## macOS 関連以外の Orbs

macOS 関連以外の業務に関わる Orb も公開しています。

- [ngs/clamav] : コンテナ内のファイルに対して [ClamAV] を使って、マルウェアが含まれていないか検査します
- [ngs/dotnet] : .NET Core 向けに開発されたプロジェクトを [.NET CLI] を使い操作します。

今回紹介した、macOS 向けのものも含めて、公開している Orbs は、まだ様々なユースケースに対応できているとは言えません。

是非、活用いただき、[GitHub Issues] でフィードバックをいただけたらと思います。

[CircleCI Advent Calendar 2018]: https://qiita.com/advent-calendar/2018/circleci
[CircleCI Orbs Registry]: https://circleci.com/orbs/registry/
[fastlane]: https://fastlane.tools/
[macOS サポート]: https://circleci.com/blog/one-more-thing-apple-developers-can-now-build-for-macos-ios-tvos-and-watchos-on-circleci-2-0/
[ngs/carthage]: https://circleci.com/orbs/registry/orb/ngs/carthage
[ngs/fastlane]: https://circleci.com/orbs/registry/orb/ngs/fastlane
[ngs/swiftlint]: https://circleci.com/orbs/registry/orb/ngs/swiftlint
[ngs/danger]: https://circleci.com/orbs/registry/orb/ngs/danger
[ngs/dotnet]: https://circleci.com/orbs/registry/orb/ngs/dotnet
[ngs/clamav]: https://circleci.com/orbs/registry/orb/ngs/clamav
[Danger]: https://danger.systems/
[SwiftLint]: https://github.com/realm/SwiftLint
[ClamAV]: https://www.clamav.net/
[.NET CLI]: https://docs.microsoft.com/en-us/dotnet/core/tools/
[GitHub Issues]: https://github.com/ngs/circleci-orbs/issues
