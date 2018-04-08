---
title: "Nightwatch.js の E2E テストでメールの配信をテストする"
description: "Nightwatch.js で書いた E2E テストプロジェクトで、Mandrill と RequestBin を使ってメールの配信もテストするサンプルプロジェクトを公開しました。"
date: 2016-09-08 17:00
public: true
tags: nightwatch, javascript, e2e, test, requestbin, email, mandrill
alternate: true
ogp:
  og:
    image:
      '': https://ja.ngs.io/images/2016-09-08-nightwatch-mail-test/og.png
      type: image/png
      width: 992
      height: 525
---

![Screenshot](2016-09-08-nightwatch-mail-test/screen.gif)

[Nightwatch.js] で書いた E2E テストプロジェクトで、[Mandrill] と [RequestBin] を使ってメールの配信もテストするサンプルプロジェクトを公開しました。

**[ngs/nightwatch-mail-example on GitHub]**

このサンプルプロジェクトは [Hacker News Letter] を購読・購読解除を行うユーザーの操作を実行しています。

READMORE

テストコードは以下の様な書き方です:

```js
page.navigate()
//
// Mandrill のメールルートを作成する
.createEmailRoute(email)
//
// フォーム入力
.waitForElementVisible('@form')
.clearValue('@email')
.setValue('@email', email)
.click('@submit')
//
// 完了画面に遷移
.waitForElementNotPresent('@form')
.assert.urlEquals(page.url + 'almostfinished.html')
//
// 指定した件名のメールの受信を確認
.assert.receivedEmailSubjectEquals(email,
  'Hacker Newsletter: Please Confirm Subscription')
//
// 指定した文字列が HTML 本文に含まれるメールの受信を確認
.assert.receivedEmailHTMLBodyContains(email,
  '<a class="button" href="https://hackernewsletter.us1.list-manage.com/subscribe/confirm?u=')
```

[全てのコードを見る](https://github.com/ngs/nightwatch-mail-example/blob/master/tests/hackernewsletter.js).

## 動機

弊社では最近 [Nightwatch.js] を製品の E2E テスト実装に導入し、とても簡単でシンプルに Web アプリケーションのテストコードを記述できるので気に入りました。。

テストコードを書いている最中、メールの受信を介したユーザーフローのテストコードを書こうと思い、[Nightwatch.js] を拡張して、カスタムアクションとアサージョンを実装しました。

ref: [Extending Nightwatch - Nightwatch Developer Guide](http://nightwatchjs.org/guide#extending)

## 導入方法

### 1. Mandrill の受信ドメイン (Inbound Domain) を設定する

まず、[Mandrill のドキュメント]を参考にして、受信用のメールドメイン (Inbound Email Domain) を設定します。

ドメインを入力し、[Inbound Domains] 画面の青い _+ Add_ ボタンをクリックするだけです。

![Inbound Domains](2016-09-08-nightwatch-mail-test/inbound-domains.png)

ドメインを追加したら、_MX Setup_ ポップアップに記載されている DNS レコードを追加します。

![MX Setup](2016-09-08-nightwatch-mail-test/mx-setup.png)

### 2. Mandrill の API キーを取得する

次に、Mandrill の API を[設定画面]から取得します。

![API Key](2016-09-08-nightwatch-mail-test/api-key.png)

間違えて実際にメールを誰かに送ってしまわないために、_Test Key_ チェックボックスはオンにすることをお勧めします。

### 3. (任意) 自身の RequestBin を使う

配信されたメール [RequestBin] で他の人でも閲覧ができます。もしアプリケーションから配信されるメールを一般から閲覧できることに懸念がある場合には、自身の [RequestBin] を [Heroku] や [IBM Bluexix] に [オープンソースの RequestBin] をデプロイすることで、利用できます。

```sh
git clone git://github.com/Runscope/requestbin.git
cd requestbin

heroku create
heroku addons:add heroku-redis
heroku config:set REALM=prod

git push heroku master
```

### 4. 環境変数

サンプルプロジェクトを実行するために、上記の手順で取得した情報を環境変数に書き出します。

自分は [direnv]　をローカル環境変数の管理に使っています:

```sh
echo "export MANDRILL_API_KEY=${YOUR_API_KEY_HERE}" >> .envrc
echo "export MAIL_DOMAIN=${YOUR_MAIL_DOMAIN_HERE}" >> .envrc

# If you set up your own RequestBin in Step 3
echo "export REQUEST_BIN_HOST=https://${YOUR_HEROKU_APP}.herokuapp.com" >> .envrc

# Allow new environment variables
direnv allow
```

### 5. NPM!

これで、`npm` コマンドを使ってサンプルテストスイートを実行できます。

```sh
npm install # for first time
npm test
```

## カスタムアサージョンとコマンド

機能拡張のファイルレイアウトは以下の様になっています:

```sh
lib
├── custom_assertions
│   ├── receivedEmailHTMLBodyContains.js
│   ├── receivedEmailSubjectContains.js
│   └── receivedEmailSubjectEquals.js
├── custom_commands
│   ├── checkEmails.js
│   ├── createEmailRoute.js
│   └── deleteEmailRoutes.js
├── globals.js
└── page_objects
    └── hackernewsletter.js # example specific file
```


[設定ファイル] (デフォルトで `nightwatch.json`) からそれらを指定します。

```js
{
  "custom_commands_path": "./lib/custom_commands",
  "custom_assertions_path": "./lib/custom_assertions",
  "page_objects_path": "./lib/page_objects",
  "globals_path": "./lib/globals.js",
  // snip ...
}
```

## もっとアサージョンを追加する

サンプルプロジェクトでは `receivedEmailHTMLBodyContains`, `receivedEmailSubjectContains`, `receivedEmailSubjectEquals` を実装しました。

もし `from_email` や `attachments` などの他のフィールドをテストしたい場合には、既存の実装をフォークして、アサージョンを追加することができます。 ([一覧を見る])

```js
const util = require('nightwatch/lib/util/utils');

exports.assertion = function receivedEmailSubjectEquals(address, expected, msg) {
  const DEFAULT_MSG = 'Testing if <%s> received with subject equals to "%s".';
  this.message = msg || util.format(DEFAULT_MSG, address, expected);

  this.expected = function() {
    return expected;
  };

  this.pass = function(value) {
    const expected = this.expected();
    return value.filter(function(email) {
      return email.subject === expected;
      // use indexOf(expected) !== -1 for *contains* implementation.
    }).length > 0;
  };

  this.value = function(result) {
    return result || [];
  };

  this.command = function(callback) {
    return this.api.checkEmails(address, callback);
  };

}
```

もし、便利なアサージョンを実装したら、是非 [リポジトリをフォーク] してプルリクエストを送って頂けると幸いです！

Happy testing!

[Nightwatch.js]: http://nightwatchjs.org/
[ngs/nightwatch-mail-example on GitHub]: https://github.com/ngs/nightwatch-mail-example
[Hacker News Letter]: http://www.hackernewsletter.com/
[Mandrill]: https://mandrillapp.com/
[RequestBin]: http://requestb.in/
[Mandrill のドキュメント]: https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview#set-up-an-inbound-domain
[Inbound Domains]: https://mandrillapp.com/inbound
[設定画面]: https://mandrillapp.com/settings/index
[Heroku]: https://www.heroku.com/
[IBM Bluexix]: http://www.ibm.com/cloud-computing/bluemix/
[オープンソースの RequestBin]: https://github.com/Runscope/requestbin
[direnv]: http://direnv.net/
[設定ファイル]: http://nightwatchjs.org/guide#settings-file
[一覧を見る]: https://mandrill.zendesk.com/hc/en-us/articles/205583197-Inbound-Email-Processing-Overview#inbound-events-format
[リポジトリをフォーク]: https://github.com/ngs/nightwatch-mail-example/fork
