---
title: Hubot スクリプトを gulp と mocha でテスト駆動開発する
description: Hubo スクリプトに gulp と mocha で実行するユニットテストを追加しました。
date: 2014-06-13 12:20
public: true
tags: hubot, tdd, gulp, mocha, test, npm
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

READMORE

package.json
------------

`devDependencies` に以下のパッケージを追加しました。

```js
"devDependencies": {
  "hubot": "^2.7.5",
  "gulp": "^3.7.0",
  "coffee-script": "^1.7.1",
  "gulp-coffee": "^2.0.1",
  "gulp-util": "^2.2.16",
  "hubot-mock-adapter": "^1.0.0",
  "gulp-mocha": "^0.4.1",
  "nock": "^0.34.1",
  "chai": "^1.9.1",
  "gulp-clean": "^0.3.0",
  "gulp-coffeelint": "^0.3.3",
  "gulp-watch": "^0.6.5"
}
```


テスト用のモジュールを読み込む
-------------------------

以下のモジュールを採用しました。

- `expect` マッチャーを使うための **[Chai Assertion Library]**。
- 偽装 HTTP レスポンスを行うための **[nock]**。

`yourscript_spec.coffee` の先頭に以下のコードを追加します。

```coffee
# Hubot classes
Robot = require("hubot/src/robot")
TextMessage = require("hubot/src/message").TextMessage

# Load assertion methods to this scope
chai = require 'chai'
nock = require 'nock'
{ expect } = chai
```


偽装 Hubot アダプタ
-----------------

**[hubot-mock-adapter]** は `send`, `reply`, `topic`, `play` イベントを即時に実行する、シンプルな Hubot アダプタです。

`mock-adapter` を使って [Robot] インスタンスを作成します。

```coffee
robot = new Robot null, 'mock-adapter', yes, 'TestHubot'
```


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

```coffee
robot.adapter.on 'connected', ->
  # Project script
  robot.loadFile path.resolve('.', 'src', 'scripts'), 'browserstack.coffee'
  # Path to scripts bundled in hubot npm module
  hubotScripts = path.resolve 'node_modules', 'hubot', 'src', 'scripts'
  robot.loadFile hubotScripts, 'help.coffee'
```


`hubot help` コマンドは [help.coffee] で実装されいます。


help コマンドをテストする
---------------------

`Robot:loadFile` メソッドは、非同期でスクリプトを読み込み、コマンド例をパースします。

なので、実際にそのコマンドが読み込まれたか確認してから、scope を抜ける必要があります。

```coffee
do waitForHelp = ->
  if robot.helpCommands().length > 0
    do done
  else
    setTimeout waitForHelp, 100
```


それで `help` コマンドの応答をテストすることができます。

```coffee
describe 'help', ->
  it 'should have 3', (done)->
    expect(robot.helpCommands()).to.have.length 3
    do done

  it 'should parse help', (done)->
    adapter.on 'send', (envelope, strings)->
      try
        expect(strings[0]).to.equal """
        TestTestHubot help - Displays all of the help commands that TestHubot knows about.
        TestTestHubot help <query> - Displays all help commands that match <query>.
        TestTestHubot screenshot me <url> - Takes screenshot with Browser Stack.
        """
        do done
      catch e
        done e
    adapter.receive new TextMessage user, 'TestHubot help'
```


[Hubot v2.7.5] は、ヘルプのパース処理に、接頭辞を2度付与するバグがあります。

修正して、[pull request#712] を送り、マージされました。(まだ npm では公開されていません。)

イベントハンドラで例外を受け取る
--------------------------

イベントハンドラ内でテストに失敗すると、`chai.AssertionError` が投げられ、そのままだと、プロセスを終了してしまいます。

`try catch` で囲んで、もし例外を受け取った場合は、`done` メソッドの引数に、エラーオブジェクトを渡します。

```coffee
it 'should handle json parse error', (done)->$
  adapter.on 'send', (envelope, strings)->
    try
      expect(strings[0]).to.equal 'Wont be sent'
      do done
    catch e
      done e
  adapter.receive new TextMessage user, 'TestHubot help'
```


偽装 HTTP
---------

偽装 HTTP レスポンスを行うために、[nock] を採用しました。[nock] は、ネイティブ実装の [http.ClientRequest] モジュールのレスポンスを上書きします。

```coffee
nock('http://www.browserstack.com')
  .post('/screenshots')
  .reply 200, job_id: 'abcd1234' # JSON response

```


[nock] は、全ての HTTP 通信をブロックする機能があるので、`beforeEach` で `nock.disableNetConnect()` を実行して、有効にします。

```coffee
do nock.disableNetConnect
http.get 'http://google.com/'
# this code throw NetConnectNotAllowedError with message
# Nock: Not allow net connect for "google.com:80"

```


詳しくは [nock のドキュメント]を参照してください。

afterEach でお掃除するもの
-----------------------

### HTTP サーバーを閉じる

[express] サーバーを閉じないと、次のテストで `Error: listen EADDRINUSE` (ポートがほかで使われている) が発生して、クラッシュしてしまいます。

```coffee
robot.server.close()
```


### 偽装 HTTP を掃除

もし、エラーハンドリングのテストを前に行っていた場合、次のテストで同じエラーが発生してしまうので、`nock.cleanAll()` を実行して、偽装 HTTP を掃除します。

```coffee
nock.cleanAll()
```


gulpfile.coffee
---------------

バージョン 3.7.0 から gulp は CoffeeScript で書かれた gulpfile をサポートしています。

gulp watch がテストに失敗すると終了する
----------------------------------

[gulp-watch] は何もしないと、テスト失敗時に終了してしまいます。

以下の様に、エラーハンドラ内で `end` イベントを発生させ、これを回避します。

```coffee
gulp.task 'watch', ->
  gulp.src(['src/**/*.coffee', 'spec/*.coffee'])
    .pipe watch(files)->
      files
        .pipe(coffee(bare: yes)
          .pipe(mocha reporter: process.env.MOCHA_REPORTER || 'nyan')
          .on('error', -> @emit 'end'))
```


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
