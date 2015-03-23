---
title: "iOS アプリの継続ビルドを Circle CI に変更した"
description: "今まで Travis CI で設定していた iOS アプリのビルドを Circle CI に変更しました。"
date: 2015-03-24 06:40
public: true
tags: circleci, ios, ci, xcode, apple, onairlog
alternate: false
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2015-03-24-circleci-ios/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2015-03-24-circleci-ios/main.jpg)

今まで [Travis CI で設定していた](/2014/10/13/xcode6/) iOS アプリのビルドを [Circle CI] に変更しました。

- [ngs/onairlog-ios on CircleCI](https://circleci.com/gh/ngs/onairlog-ios)
- [ngs/onairlog-ios on GitHub](https://github.com/ngs/onairlog-ios)

現在、iOS ビルドの機能は Experimental Settings として提供されています。

https://circleci.com/mobile

READMORE

## TOC

- 前準備
  - [依存ライブラリのインストール](#依存ライブラリのインストール)
  - [鍵と証明書の読み込み](#鍵と証明書の読み込み)
	- [プロビジョニングファイルのダウンロード](#プロビジョニングファイルのダウンロード)
	- [環境変数のエクスポート](#環境変数のエクスポート)
- [テスト実行](#テスト実行)
- デプロイ
	- [AdHoc ビルド](#adhoc-ビルド)
	- [DeployGate へデプロイ](#deploygate-へデプロイ)
	- [Release ビルド作成](#release-ビルド作成)
	- [iTunes Connect へデプロイ (WIP)](#itunes-connect-へデプロイ-(wip))
- その他
  - [Xcode 6.2](#xcode-6.2)
  - [所感](#所感)
  - [TODOs](#todos)
  - [参考にしたページ](#参考にしたページ)

## 環境変数

件のアプリのソースコードは、GitHub 上の公開リポジトリで管理しているため、鍵やプロビジョニングファイルは、バージョン管理に追加したくありませんでした。

その為、各種設定を Dashboard の環境設定 (_Project Settings_ > _Environment variables_) から追加しました。

| Name                                      | Description |
| ----------------------------------------- | ----------- |
| `APPLE_AUTHORITY_BASE64`                  | [Apple Worldwide Developer Relations Certification Authority] (中間認証局証明書) の Base64  |
| `DEPLOYGATE_API_TOKEN`                    | [Deploy Gate] の アカウント API Key |
| `DEPLOYGATE_USERNAME`                     | [Deploy Gate] のユーザー名 |
| `DEVELOPER_NAME`                          | 開発者名 (= Distribution 証明書の Common Name)<br>例: `iPhone Distribution: LittleApps Inc. (3Y8APYUG2G)` |
| `DISTRIBUTION_CERTIFICATE_BASE64`         | Distribution 証明書 Base64 エンコード |
| `DISTRIBUTION_KEY_BASE64`                 | Distribution 鍵 Base64 エンコード |
| `ITUNES_CONNECT_ACCOUNT`                  | [iTunes Connect] のログイン ID (Email)  |
| `ITUNES_CONNECT_PASSWORD`                 | [iTunes Connect] のパスワード |
| `KEY_PASSWORD`                            | Distribution 鍵のパスワード |
| `ONAIRLOG802_DEPLOYGATE_DISTRIBUTION_KEY` | [Deploy Gate] のアプリ側 API Key (802 用) |
| `ONAIRLOG802_PROFILE_UUID`                | プロビジョニングファイル UUID (802 用) |
| `ONAIRLOG813_DEPLOYGATE_DISTRIBUTION_KEY` | [Deploy Gate] のアプリ側 API Key (813 用) |
| `ONAIRLOG813_PROFILE_UUID`                | プロビジョニングファイル UUID (813 用) |
| `ONAIRLOG_BITLY_ACCESS_TOKEN`             | [Bitly] のアクセストークン |

## 依存ライブラリのインストール

`bundle install` と `pod install`　は [Circle CI] が検知して、設定せずとも実行してくれます。

![](2015-03-24-circleci-ios/dependencies.png)

## 鍵と証明書の読み込み

前途の通り、証明書と鍵は Base64 エンコードして環境変数に設定し、`dependency.post` でデコード、ファイル書き込み、キーチェーンへの追加を行っています。

自身の証明書と [Apple Worldwide Developer Relations Certification Authority] を _Keychain Access.app_ で検索し、右クリックでエクスポートします。

![](2015-03-24-circleci-ios/keychain-access.png)

以下のコマンドで Base64 エンコードしたコンテンツをクリップボードにコピーし、[Circle CI] の _Project Settings_ に追加します。

```bash
cat ~/Desktop/Certificates.cer|base64|pbcopy
```

取り込み側のスクリプトです

```bash
DIR=tmp/certs
KEYCHAIN=$HOME/Library/Keychains/ios-build.keychain
KEYCHAIN_PASSWORD=`openssl rand -base64 48`
rm -rf $DIR
mkdir -p $DIR
echo $APPLE_AUTHORITY_BASE64 | base64 -D > $DIR/apple.cer
echo $DISTRIBUTION_KEY_BASE64 | base64 -D > $DIR/dist.p12
echo $DISTRIBUTION_CERTIFICATE_BASE64 | base64 -D > $DIR/dist.cer

security create-keychain -p "$KEYCHAIN_PASSWORD" ios-build.keychain

security import $DIR/apple.cer -k $KEYCHAIN -T /usr/bin/codesign
security import $DIR/dist.cer  -k $KEYCHAIN -T /usr/bin/codesign
security import $DIR/dist.p12  -k $KEYCHAIN -T /usr/bin/codesign -P "$KEY_PASSWORD"

security list-keychain -s $KEYCHAIN
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN
rm -rf $DIR
```

## プロビジョニングファイルのダウンロード

プロビジョニングのダウンロードには [nomad] シリーズの [cupertino] を使います。

```bash
bundle exec ios profiles:download:all --type distribution -u "$ITUNES_CONNECT_ACCOUNT" -p "$ITUNES_CONNECT_PASSWORD" >/dev/null 2>&1
mkdir MobileProvisionings
mv *.mobileprovision MobileProvisionings
```

以下のスクリプトで UUID のファイル名に変更し、`Library` ディレクトリに移動します。

```bash
BASE=~/Library/MobileDevice/Provisioning\ Profiles
mkdir -p "$BASE"
for file in MobileProvisionings/*.mobileprovision; do
  uuid=`grep UUID -A1 -a "$file" | grep -io "[-A-Z0-9]\{36\}"`
  extension="${file##*.}"
  echo "$file -> $uuid"
  cp -f "$file" "$BASE/$uuid.$extension"
done
ls -lsa "$BASE"
```

## テスト実行

`XCODE_WORKSPACE` , `XCODE_SCHEME` だけを環境変数に設定して、[Circle CI] 既定のテストコマンドを実行しています。

```yaml
# circle.yml 抜粋
machine:
  environment:
    XCODE_SCHEME: OnAirLogTests
    XCODE_WORKSPACE: OnAirLog.xcworkspace
```

![](2015-03-24-circleci-ios/test.png)

## AdHoc ビルド

ビルドとデプロイには、[nomad] シリーズの [shenzhen] を使います。

[shenzhen] と [cupertino] で、依存している [commander] のバージョンがコンフリクトしていたので、フォークして修正したものを使っています。

```rb
# Gemfile
gem 'cupertino', github: 'ngs/cupertino', branch: 'fix-conflict-commander'
gem 'shenzhen', '0.13.1'
```

参照: [Fix conflicting commender version with shenzhen #193 on nomad/cupertino][pr193]

複数のアプリをビルドするので、circle.yml のビルドプロセス定義のところで、個別に変数名を設定します。

```yaml
- /bin/bash Scripts/build-adhoc.sh:
    environment:
      APPNAME: OnAirLog813
      DEPLOYGATE_DISTRIBUTION_KEY: $ONAIRLOG813_DEPLOYGATE_DISTRIBUTION_KEY
- /bin/bash Scripts/build-adhoc.sh:
    environment:
      APPNAME: OnAirLog802
      DEPLOYGATE_DISTRIBUTION_KEY: $ONAIRLOG802_DEPLOYGATE_DISTRIBUTION_KEY
```

[shenzhen] の `ipa build` コマンドで `--embed` 引数で AdHoc 用プロビジョニングファイルを指定して、ビルドします。

```bash
bundle exec ipa build \
  --workspace "$XCODE_WORKSPACE" \
  --scheme "$APPNAME" \
  --configuration Release \
  --destination Distribution/AdHoc \
  --embed MobileProvisionings/${APPNAME}AdHoc.mobileprovision \
  --identity "$DEVELOPER_NAME"
```

## DeployGate へデプロイ

[shenzhen] の `ipa distribute:deploygate` コマンドでデプロイします。

```bash
bundle exec ipa distribute:deploygate \
  --file Distribution/AdHoc/${APPNAME}.ipa \
  --api_token $DEPLOYGATE_API_TOKEN \
  --distribution_key $DEPLOYGATE_DISTRIBUTION_KEY \
  --release_note $RELEASE_NOTE \
  --visibility public \
  --user_name $DEPLOYGATE_USERNAME
```

## Release ビルド作成

[shenzhen] の `ipa build` コマンドで `--embed` 引数で Distribution 用プロビジョニングファイルを指定して、ビルドします。

```bash
bundle exec ipa build \
  --workspace "$XCODE_WORKSPACE" \
  --scheme "$APPNAME" \
  --configuration Release \
  --destination Distribution/Release \
  --embed MobileProvisionings/${APPNAME}Distribution.mobileprovision \
  --identity "$DEVELOPER_NAME"
```

## iTunes Connect へデプロイ (WIP)

最後に、`master` ブランチへのマージを契機に、[iTunes Connect] への配布を行おうとしました。

しかし、日本時間 2015-03-24 02:50 まで [iTunes Connect の障害でメールが届かなかった](https://devforums.apple.com/message/1116750)ので、CI 用のアカウントを作成できず、断念していました。

ローカルで [shenzhen] の `ipa distribute:itunesconnect` コマンドで通信できることを確認しました。

```bash
bundle exec ipa distribute:itunesconnect \
  --warnings --errors \
  --file Distribution/Release/${APPNAME}.ipa \
  --account $ITUNES_CONNECT_ACCOUNT \
  --password $ITUNES_CONNECT_PASSWORD \
  --apple-id $APPLE_ID
```

もう一つ問題があり、既にリリース済みのバージョンの場合、 `The train version '2.1.0' is closed for new build submissions` というエラーレスポンスが返ってきます。

```
Package Summary:

1 package(s) were not uploaded because they had problems:
  /Users/ngs/src/onairlog-ios/Package.itmsp - Error Messages:
    ERROR ITMS-90189: "Redundant Binary Upload. There already exists a binary upload with build '157' for version '2.1.0'"
    ERROR ITMS-90186: "Invalid Pre-Release Train. The train version '2.1.0' is closed for new build submissions"
    ERROR ITMS-90062: "This bundle is invalid. The value for key CFBundleShortVersionString [2.1.0] in the Info.plist file must contain a higher version than that of the previously approved version [2.1.0]."
```

Build 番号が同じである、`There already exists a binary upload with build '157' for version '2.1.0'` というエラーについては、
[Circle CI] のビルド番号 `$CIRCLE_BUILD_NUM` を使う様にタスクを追加する予定です。

解決案として、新バージョンリリース後、すぐに次バージョンの準備を [iTunes Connect] 側で行い、Info.plist のバージョンも上げる運用にしようかと思います。

## Xcode 6.2

[OnAirLog] は [Apple Watch] 対応の準備をしました。

![](2015-03-24-circleci-ios/applewatch.png)

[ watch #15 on ngs/onairlog-ios][pr15]

しかし、[Circle CI] の [Xcode は、まだ 6.1](https://circleci.com/docs/ios#software-versions) の様です。

![](2015-03-24-circleci-ios/swversions.png)

故に、エラーでビルドは終了します。

```
target specifies product type 'com.apple.product-type.application.watchapp', but there's no such product type for the 'iphonesimulator' platform
```

https://circleci.com/gh/ngs/onairlog-ios/30

画面右下の問い合わせアイコンから、いつ対応すんの？って聞いたら、明確なリリース日は決まってないとの返信を頂きました。

![](2015-03-24-circleci-ios/intercom.png)

気長に待とうと思います。

## 所感

OSS なので、Travis CI でも、`.org` で無料で問題なく使わせて頂いていました。

ただ、[Circle CI] に移行したことで、以下の様な点で、メリットがありました。

- 会社で使っているので知見が生かせる
- キューが回ってくるのを待つ必要があったのが無くなった
- キャッシュが使える
- Build Artifacts が使える (これが大きい)

これで味をしめたので、他のアプリにも設定していこうと思います。


## TODOs

- [ ] [iTunes Connect] デプロイ何とかする
- [ ] DL ページと一緒に Ad Hoc 版を S3 デプロイする
- [ ] DL ページができたら Slack 通知する

## 参考にしたページ

- [Test iOS applications on CircleCI Documentations](https://circleci.com/docs/ios)
- [Circle CIでiOSアプリのリリース作業を自動化](http://blog.ishkawa.org/2015/01/07/1420556760/)
- [大晦日〜正月にiOSでCircleCIを試したので振り返ってみた](http://qiita.com/saku/items/9c093535967e4452a8d0)
- [DeployGateに移行しよう！ (煽りタイトル省略)](http://qiita.com/appwatcher/items/632460e15fbdb81b7a71)

[Apple Worldwide Developer Relations Certification Authority]: https://developer.apple.com/jp/documentation/Xcode/Conceptual/ios_development_workflow/190-iOS_Development_Troubleshooting_Guide/ios_development_troubleshooting.html#//apple_ref/doc/uid/TP40007959-CH25-SW7
[Deploy Gate]: https://deploygate.com/
[iTunes Connect]: https://itunesconnect.apple.com/
[Bitly]: http://dev.bitly.com/
[dgacct]: https://deploygate.com/settings
[nomad]: http://nomad-cli.com/
[cupertino]: https://github.com/nomad/cupertino
[shenzhen]: https://github.com/nomad/shenzhen
[Circle CI]: https://circleci.com/
[commander]: https://github.com/tj/commander
[pr193]: https://github.com/nomad/cupertino/pull/193
[pr15]: https://github.com/ngs/onairlog-ios/pull/15
[Apple Watch]: http://www.apple.com/jp/watch/
[OnAirLog]: /2014/10/17/onairlog/
