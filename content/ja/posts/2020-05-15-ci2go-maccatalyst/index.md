---
title: CI2Go for macOS をリリースしました
description: CircleCI クライアントの CI2Go macOS 版を公開しました。
date: 2020-05-15 00:00
public: true
tags: ci2go, ios, macos, release, maccatalyst, circleci, ci
alternate: true
ogp:
  og:
    image:
      '': 2020-05-15-ci2go-maccatalyst/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](main.jpg)

iPhone, iPad, Apple Watch 向け CircleCI クライアント [CI2Go] の macOS 版を公開しました。

iOS 版, macOS 版 共に同じ URL からダウンロードいただけます。

[![](/images/appstore.svg.svg)][AppStore]

製品サイト: [ci2go.app]

このアプリは、既存 iOS アプリのコードベースを [Mac Catalyst] を用いて移植したものです。

READMORE

iOS 版, mac 版 両新バージョンは、以下の新機能を含みます。

## ダークモード

![](dark-and-light.jpg)

[ダークモード] に対応し、カラースキーム選択の機能の提供を終了しました。

## iPad キーボードショートカット

![](shortcuts.png)

iPad キーボードショートカットが利用いただけるようになりました。

<kbd>&#x2318; \[</kbd> で戻る、<kbd>&#x2318; R</kbd> で再読み込み、<kbd>&#8997; &#8679;　&#x2318; L</kbd> でログアウトを行います。

## WIP: Workflows

CircleCI [Workflows] の対応は、まだ完全に行われていませんが、将来のマイルストーンには含まれています。

## アップデートの舞台裏

![](workflow.png)

もちろん、Mac Catalyst アプリの継続的デリバリーも、iOS 版同様設定しました。

また、パッケージ管理を [Carthage] から [Swift Package Manager] に変更しました。

これらは、公開 [GitHub リポジトリ] に含まれており、どなたでも閲覧いただけます。

私のように Mac Catalyst のアプリを CircleCI で構築しようとする、他の開発者の助けになればと幸いです。

以下のようなワークアラウンドを行ったりしました。

- macOS プラットフォームで、依存ビルドを含むと Swift パッケージのビルドが失敗する。
    - 例: `multiple configured targets of 'KeychainAccess' are being created for macOS`
    - ビルドターゲットを複製し、依存ビルドを削除しました。
    - 参照: [Swift PM app in Xcode 11 (beta 5) gets four “My Mac” platform options]
- [fastlane match] で Mac Catalyst 向けのプロビジョニングが作成できない
    - `platform: 'macos'` を指定すると Mac 向けのものが作られる。
    - `skip_provisioning_profiles` を `true` に設定、`.provisioningprofile` ファイルをバージョン管理に追加し、CI のステップで ` ~/Library/MobileDevice/Provisioning Profiles/` にコピーするようにしました。

        ```rb
        match(
          type: 'development',
          app_identifier: %w(com.ci2go.ios.Circle),
          skip_provisioning_profiles: true,
          platform: 'macos'
        )
        ```

- [fastlane deliver] が `reject_if_possible: true` を設定した再、`platform` を `osx` に設定しても、iOS のバイナリーを取り下げる。
    - 今の所 Mac 版では、 `reject_if_possible` を `false` に設定し、新しいバイナリーを提出する必要がある場合は手動で取り下げています。
- [fastlane deliver] が Mac アプリの審査提出に失敗する。
    - [Spaceship] が App Store Connect API のレスポンス形式に対応できていない様子。
    - ref: [tunes_client.rb]
    - 例外を `rescue` しています。

        ```rb
        rescue NoMethodError => e
          puts e
          raise e unless e.message == %q(undefined method `fetch' for nil:NilClass)
          puts "... Caught error, but omitting"
        end
        ```

## 応援する

[GitHub Sponsors] のページを公開しました。もしよかったら CI2Go の開発を応援してください 🙇‍♂️

[CI2Go]: https://ci2go.app
[Mac Catalyst]: https://developer.apple.com/mac-catalyst/
[ダークモード]: https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/dark-mode/
[Workflows]: https://circleci.com/docs/ja/2.0/workflows/
[AppStore]: https://itunes.apple.com/app/id940028427?mt=8
[GitHub リポジトリ]: https://github.com/ngs/ci2go
[Swift Package Manager]:https://swift.org/package-manager/
[Carthage]: https://github.com/Carthage/Carthage
[fastlane match]: https://docs.fastlane.tools/actions/match/
[fastlane deliver]: https://docs.fastlane.tools/actions/deliver/
[Swift PM app in Xcode 11 (beta 5) gets four “My Mac” platform options]: https://forums.swift.org/t/swift-pm-app-in-xcode-11-beta-5-gets-four-my-mac-platform-options/27521
[tunes_client.rb]: https://github.com/fastlane/fastlane/blob/feb8cc09c9976f7f460203cf9486fd28d31f6955/spaceship/lib/spaceship/tunes/tunes_client.rb#L1138
[Spaceship]: https://github.com/fastlane/fastlane/tree/master/spaceship
[ci2go.app]: https://ci2go.app
[GitHub Sponsors]: https://github.com/sponsors/ngs