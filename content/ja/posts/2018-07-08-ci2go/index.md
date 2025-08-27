---
title: "CI2Go Today ウィジェット対応"
description: "Today ウィジェットに対応した CI2Go 2.1.0 をリリースしました"
date: 2018-07-08 09:00
public: true
tags: ci2go, circleci, ios
alternate: true
ogp:
  og:
    image:
      '': 2018-07-08-ci2go/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](main.jpg)

iPhone と iPad 向け [CircleCI] クライアント  [CI2Go] バージョン 2.1.0 を公開しました。

[![](/images/appstore.svg.svg)][AppStore]

バージョン 2.1.0 は以下の更新を含みます:

- Today ウィジェット
- SSH 接続
- 端末上の成果物を削除
- URL でアプリを開く

READMORE

## Today ウィジェット

![](widget.jpg)

CI2Go Today ウィジェットを [Today] ビューに追加できます。

選択したプロジェクト、ブランチ、または全てのフォローしているプロジェクトの直近5件のビルドが表示されます。

## SSH 接続

![](ssh.png)

SSH 接続が有効なビルドの実行中で Panic の [Prompt] のような `ssh://` URI スキームに対応しているクライアントがインストールされている場合、`SSH` セクションが表示されるようになりました。

コンテナの行を選択することで、SSH クライアントを起動します。

## 端末上の成果物を削除

![](artifacts.png)

テーブルの行を左にスワイプして出てくるゴミ箱アイコンから、ダウンロード済のビルド成果物を削除できます。

## URL でアプリを開く

`chttps://`, `ci2go://`, `ci2go+https://` の URI スキームに対応しました。

CircleCI のビルド URL のプロトコル部分を以下のように変更することで、CI2Go を起動できます。

[https://circleci.com/gh/circleci/frontend/3439] から [ci2go://circleci.com/gh/circleci/frontend/3439]

不具合などありましたら、 [イシュー] を起票いただけると幸いです。

[CI2Go]: https://itunes.apple.com/app/id940028427?mt=8
[AppStore]: https://itunes.apple.com/app/id940028427?mt=8
[CircleCI]: https://circleci.com
[イシュー]: https://github.com/ngs/ci2go/issues/new
[https://circleci.com/gh/circleci/frontend/3439]: https://circleci.com/gh/circleci/frontend/3439
[ci2go://circleci.com/gh/circleci/frontend/3439]: ci2go://circleci.com/gh/circleci/frontend/3439
[Prompt]: https://panic.com/prompt/
[Today]: https://support.apple.com/ja-jp/ht207122
