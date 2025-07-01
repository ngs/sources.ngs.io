---
title: "Hubot スクリプトを gulp と mocha でテスト駆動開発する"
description: "Hubo スクリプトに gulp と mocha で実行するユニットテストを追加しました。"
date: 2014-06-13T12:20:00+09:00
public: true
tags: ["hubot", "tdd", "gulp", "mocha", "test", "npm"]
alternate: true
ogp:
  og:
    image:
      '': https://avatars0.githubusercontent.com/u/480938?s=460
      type: image/png
      width: 460
      height: 460
---

今まで [3つの Hubot スクリプト]を作って、[npm][npm] で公開していますが、ユニットテストがないのが、気持ち悪かった & 非効率だったので、[gulp] と [mocha] を使って、ユニットテストを追加しました。

<!--more-->

package.json
------------

`devDependencies` に以下のパッケージを追加しました。

{{< partial "2014-06-13-tdd-hubot-scripts/package.json.html.md" >}}

テスト用のモジュールを読み込む
-------------------------

以下のモジュールを採用しました。

- `expect` マッチャーを使うための **[Chai Assertion Library]**。
- 偽装 HTTP レスポンスを行うための **[nock]**。

`yourscript_spec.coffee` の先頭に以下のコードを追加します。

{{< partial "2014-06-13-tdd-hubot-scripts/require.coffee.html.md" >}}

偽装 Hubot アダプタ
-----------------

**[hubot-mock-adapter]** は `send`", "`reply`", "`topic`", "`play` イベントを即時に実行する、シンプルな Hubot アダプタです。

`mock-adapter` を使って [Robot] インスタンスを作成します。

{{< partial "2014-06-13-tdd-hubot-scripts/new-robot.coffee.html.md" >}}

これは、以下の意味があります。

- npm モジュールからアダプタを読み込む。
- [hubot-mock-adapter] を採用する。
- HTTP サーバーは有効。
- `TestHubot ...` が先頭に付いているメッセージに反応する。

自分のスクリプトを読み込む
---------------------

`Robot:loadFile` メソッドを実行して、テストを行いたいスクリプトを読み込みます。

This method loads listeners and parses command.

このメソッドは、リスナと、コメントに記載されているコマンド例をパースします。

アダプタがデータソースに接続されている必要があるので、`connected` イベントハンドラ内で実行します。

{{< partial "2014-06-13-tdd-hubot-scripts/robot-load-file.coffee.html.md" >}}

`hubot help` コマンドは [help.coffee] で実装されいます。


help コマンドをテストする
---------------------

`Robot:loadFile` メソッドは、非同期でスクリプトを読み込み、コマンド例をパースします。

なので、実際にそのコマンドが読み込まれたか確認してから、scope を抜ける必要があります。

{{< partial "2014-06-13-tdd-hubot-scripts/wait-for-help.coffee.html.md" >}}

それで `help` コマンドの応答をテストすることができます。

{{< partial "2014-06-13-tdd-hubot-scripts/describe-help.coffee.html.md" >}}

[Hubot v2.7.5] は、ヘルプのパース処理に、接頭辞を2度付与するバグがあります。

修正して、[pull request#712] を送り、マージされました。(まだ npm では公開されていません。)

イベントハンドラで例外を受け取る
--------------------------

イベントハンドラ内でテストに失敗すると、`chai.AssertionError` が投げられ、そのままだと、プロセスを終了してしまいます。

`try catch` で囲んで、もし例外を受け取った場合は、`done` メソッドの引数に、エラーオブジェクトを渡します。

{{< partial "2014-06-13-tdd-hubot-scripts/try-catch.coffee.html.md" >}}

偽装 HTTP
---------

偽装 HTTP レスポンスを行うために、[nock] を採用しました。[nock] は、ネイティブ実装の [http.ClientRequest] モジュールのレスポンスを上書きします。

{{< partial "2014-06-13-tdd-hubot-scripts/nock-post-reply.coffee.html.md" >}}

[nock] は、全ての HTTP 通信をブロックする機能があるので、`beforeEach` で `nock.disableNetConnect()` を実行して、有効にします。

{{< partial "2014-06-13-tdd-hubot-scripts/nock-disable-net-connect.coffee.html.md" >}}

詳しくは [nock のドキュメント]を参照してください。

afterEach でお掃除するもの
-----------------------

### HTTP サーバーを閉じる

[express] サーバーを閉じないと、次のテストで `Error: listen EADDRINUSE` (ポートがほかで使われている) が発生して、クラッシュしてしまいます。

{{< partial "2014-06-13-tdd-hubot-scripts/robot-server-close.coffee.html.md" >}}

### 偽装 HTTP を掃除

もし、エラーハンドリングのテストを前に行っていた場合、次のテストで同じエラーが発生してしまうので、`nock.cleanAll()` を実行して、偽装 HTTP を掃除します。

{{< partial "2014-06-13-tdd-hubot-scripts/nock-clean-all.coffee.html.md" >}}

gulpfile.coffee
---------------

バージョン 3.7.0 から gulp は CoffeeScript で書かれた gulpfile をサポートしています。

gulp watch がテストに失敗すると終了する
----------------------------------

[gulp-watch] は何もしないと、テスト失敗時に終了してしまいます。

以下の様に、エラーハンドラ内で `end` イベントを発生させ、これを回避します。

{{< partial "2014-06-13-tdd-hubot-scripts/gulp-watch.coffee.html.md" >}}

`mocha` パイプは `coffee` パイプにつながっていることを確認してください。

[3つの Hubot スクリプト]: https://github.com/search?q=user%3Angs+hubot&type=Repositories&ref=searchresults
[Hobot]: https://hubot.github.com
[npm]: http://npmjs.org
[gulp]: http://gulpjs.com/
[mocha]: http://visionmedia.github.io/mocha/
[hubot-mock-adapter]: https://github.com/blalor/hubot-mock-adapter
[Chai Assersion Library]: http://chaijs.com/
[nock]: https://github.com/pgte/nock
[nock のドキュメント]: https://github.com/pgte/nock#readme
[Robot]: https://github.com/github/hubot/blob/master/src/robot.coffee
[http.ClientRequest]: http://nodejs.org/api/http.html#http_class_http_clientrequest
[gulp-watch]: https://github.com/floatdrop/gulp-watch
[gulp-mocha]: https://github.com/sindresorhus/gulp-mocha
[express]: http://expressjs.com/
[Hubot v2.7.5]: https://github.com/github/hubot/commit/04b97eada0018bfc049d88f47b91bce15e54f1bc
[pull request#712]: https://github.com/github/hubot/pull/712
[help.coffee]: https://github.com/github/hubot/blob/master/src/scripts/help.coffee
