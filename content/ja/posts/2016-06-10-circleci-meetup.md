---
title: "#circleci_meetup 2016-06-10"
description: "2016-06-10 渋谷ヒカリエの DeNA さんのセミナールームで開催された #circleci_meetup で LT をしてきました。"
date: 2016-06-10 23:20
public: true
tags: circleci, meetup, ci2go
alternate: false
ogp:
  og:
    image:
      '': 2016-06-10-circleci-meetup/main.png
      type: image/png
      width: 992
      height: 525
---

![](2016-06-10-circleci-meetup/main.png)

2016-06-10 渋谷ヒカリエの DeNA さんのセミナールームで開催された [#circleci_meetup] で LT をしてきました。

[CircleCI Meetup on Connpass](http://connpass.com/event/32338/)

READMORE

## 発表内容: [CircleCI Client for iOS CI2Go](http://ci2go.com) について

開発にいたるモチベーションと、簡単な機能紹介をしました。

- https://github.com/ngs/ci2go
- http://bit.ly/ci2go-appstore

## 発表内容: CircleCI API についての要望

CI2Go を開発している上で、かなり細かく理解したつもりですが、どうしても実装上解決できなかった問題について、CircleCI への要望として発表しました。

### Pusher Auth エンドポイントの CORS 対応

1.2.0 のリリースノートで [リアルタイムログの舞台裏] として紹介している `/auth/pusher` エンドポイントが CORS 用の HTTP Header `Access-Control-Allow-Origin: *` をレスポンスしていないので、外部ドメインから Pusher の認証を得ることができないです。

```
$ curl -i "https://circleci.com/auth/pusher?circle-token=${CIRCLE_TOKEN}" \
   --data 'socket_id=123456.87654321&channel_name=private-ngs'
　
HTTP/1.1 200 OK
Date: Fri, 10 Jun 2016 07:26:49 GMT
Server: nginx
Set-Cookie: ring-session=...
Set-Cookie: ab_test_user_seed=...
Strict-Transport-Security: max-age=15724800
X-Circleci-Identity: i-45fbc4c2
X-Circleci-Request-Id: ...
X-Frame-Options: DENY
X-Route: /auth/pusher
Content-Length: 96
Connection: keep-alive
　
{"auth":"1cf6e0e755e419d2ac9a:..."}
```

JavaScript で実装された 3rd Party のウェブアプリケーションから直接リアルタイムにデータを更新できるようになり、可能性が広がるので、追加を希望しています。

### 認証フロー

CircleCI のドキュメンテーションの [Getting Started] には _Add an API token from your account dashboard._ とだけ書いてあり、ユーザーは[アカウント管理画面]に遷移して API Token を取得する以外、3rd Party のアプリケーションで認証を得る方法がありません。

その為、CI2Go の設定画面では、以下の様な表記を行い、ユーザーは画面遷移を行い、API Token をコピーしてくる必要があり、とてもユーザービリティーが悪いです。

![](2016-06-10-circleci-meetup/settings.png)

以下の様なご意見も頂いています:

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">ci2go、いきなりトークン入力しろって言われて萎えた</p>&mdash; Akinori Yamada (@stormcat24) <a href="https://twitter.com/stormcat24/status/537442011519795200">November 26, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

是非、ログイン画面からコールバックで Token を取得できるなど、何かしら認証 API を提供していただきたいと思っています。

## 発表資料

<script async class="speakerdeck-embed" data-id="06d140816038428f9a434aef4b404b85" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

## 所感

東京初の CircleCI の Meetup で、他の CircleCI ファンのエンジニアの方々と交流でき、とても有意義な会でした。

CircleCI のスタッフにもお会いでき、CI2Go について、とても喜んで頂けているみたいで嬉しかったです。

// CI2Go のバグ報告が CircleCI 側に飛んでくるらしく、申し訳ないです。

また次回開催されることを楽しみにしています。

[#circleci_meetup]: https://twitter.com/hashtag/circleci_meetup
[1.2.0 のリリースノート]: /2016/01/29/ci2go/
[リアルタイムログの舞台裏]: /2016/01/29/ci2go/#リアルタイムログの舞台裏
[Getting Started]: https://circleci.com/docs/api/#getting-started
[アカウント管理画面]: https://circleci.com/account/api
