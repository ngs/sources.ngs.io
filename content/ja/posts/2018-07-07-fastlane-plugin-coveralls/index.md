---
title: "Coveralls fastlane プラグイン"
description: "Published Coveralls plugin for fastlane"
date: 2018-07-07 23:59
public: true
tags: ruby, fastlane, ci, coveralls, testing, xcode
alternate: true
ogp:
  og:
    image:
      "": 2018-07-07-fastlane-plugin-coveralls/main.png
      type: image/png
      width: 992
      height: 525
---

![](main.png)

Xcode のテストカバレッジを [Coveralls] へアップロードする [fastlane]&nbsp;[プラグイン] と、その依存先で、単体でもコマンドラインツールとして利用できる [xccoveralls] を公開しました。

- [ngs/fastlane-plugin-coveralls][プラグイン]
- [ngs/xccoveralls][xccoveralls]

READMORE

## 使ってみる

以下のコマンドを実行して

```sh
fastlane add_plugin coveralls
```

`Fastfile` に以下の行を追加

```rb
lane :send_coveralls do
  coveralls
end
```

テストターゲットの `Code Coverage`　のチェックボックスをオンに設定し

![](checkbox.png)

`fastlane` コマンドよりコードカバレッジを送信できます

```sh
export XCCOVERALLS_REPO_TOKEN=... # Coveralls.io から自分のものを取ってくる
bundle exec fastlane send_coveralls
```

例として [CI2Go] のカバレッジを [Coveralls](https://coveralls.io/github/ngs/ci2go) で、その設定を[Fastfile](https://github.com/ngs/ci2go/blob/master/fastlane/Fastfile#L119-L124) で確認いただけます。

## 開発のきっかけ

[fastlane のアクション][xcov action] として組み込まれている [Xcov] を利用しようとしました。

しかし、Xcov はカバレッジの要約のみ保持している `.xccovreport` または `.xccoverage` の情報を取得して送信しているため、カバー行の情報まで送信しません。

そこで、Xcode 9.3 より提供されている `xcrun xccov` を利用して、新たにこのツールを実装しました。

```sh
# ファイルの一覧を取得する
$ xcrun xccov view --file-list DerivedData/Logs/Build/*.xccovarchive

# 特定のファイルのカバレッジを取得する
$ xcrun xccov view --file /Users/ngs/src/CI2Go/AppDelegate.swift \
    DerivedData/Logs/Build/*.xccovarchive
```

参照: [xccov: Xcode Code Coverage Report for Humans](https://medium.com/xcblog/xccov-xcode-code-coverage-report-for-humans-466a4865aa18)

もし何か問題がありましたら [イシュー] を起票いだたけると嬉しいです。

では XCTesting を楽しんでください 👨‍💻

[coveralls]: https://coveralls.io/
[fastlane]: https://fastlane.tools/
[プラグイン]: https://github.com/ngs/fastlane-plugin-coveralls
[xccoveralls]: https://github.com/ngs/xccoveralls
[ci2go]: https://github.com/ngs/ci2go
[xcov]: https://github.com/nakiostudio/xcov
[イシュー]: https://github.com/ngs/fastlane-plugin-coveralls/issues
[xcov action]: https://docs.fastlane.tools/actions/xcov/
