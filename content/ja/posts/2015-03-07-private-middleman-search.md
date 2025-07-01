---
title: "静的サイトジェネレーターで作ったサイトの検索 API"
description: "Middleman などの静的サイトジェネレーターを使って作ったサイトの検索 API を作りました"
date: 2015-03-07 22:00
public: true
tags: middleman, github, api, json, kaizenplatform, heroku
alternate: false
ogp:
  og:
    image:
      '': 2015-03-07-private-middleman-search/screen1.png
      type: image/png
      width: 1262
      height: 422
---

![](2015-03-07-private-middleman-search/screen1.png)

以前、このブログで [直接 GitHub API v3 を使って検索画面を作った方法][prev] を紹介しましたが、業務でも同じ方法を試み、後述の理由で、自前で簡易検索 API を作りました。

[kaizenplatform/doc-search-api on GitHub][repo]

READMORE

## 仕組み

あくまでも GitHub API の代替として作ったので、簡易な作りになっています。

- `SITEMAP_URL` からページ一覧を Redis で、ロケール別の Set にロードする: [SADD]
- GET パラメータで送られた文字列から Set 内の要素を検索する: [SSCAN]

## エンドポイント

### `GET /?lang=en&q=...`

ページを検索します。パラメータ `q` に検索語句を、`lang` にロケールを指定します。

```bash
$ curl 'https://my-doc-search.herokuapp.com/?lang=en&q=javascript'
```

```json
[{"title": "My JavaScript Tips 1", "url": "/tips/javascript/1"}]
```

### `POST /rebuild`

Redis への取り込みをトリガーします。

`timestamp` に現在時刻のエポックミリ秒、 `token` に `timestamp` と `TOKEN_SECRET` で設定した文字列を結合したものを SHA-1 ダイジェストの hex 値を指定します。

```bash
$ curl -XPOST 'https://my-doc-search.herokuapp.com/rebuild' \
    -d 'timestamp=1425731850078&token=bf222511ce3ef7775658a3ff923f4ddb25fe0d12'
```

```json
{"success": true}
```

弊社では CI ビルドプロセスで [Middleman] でサイトをデプロイ後、以下の Rake タスクでリクエストを送っています。

```rb
desc 'Request rebuilding search index'
task :rebuild_sitemap => [:env] do
  if api_base = ENV['DOC_SEARCH_API_BASE']
    require 'digest/sha1'
    require 'json'
    secret = ENV['REBUILD_TOKEN_SECRET']
    ts = (Time.now.to_f * 1000).to_i.to_s
    token = Digest::SHA1.hexdigest ts + secret
    res = %x{curl -XPOST #{api_base}/rebuild -d 'token=#{token}&timestamp=#{ts}'}
    json = JSON.parse res
    raise json['message'] if json['message']
  end
end
```

## 導入方法

[README] の Heroku ボタンから、Heroku ですぐ動く様になっています。

![](2015-03-07-private-middleman-search/screen2.png)

`NODE_ENV` はステージ名。ロケール名と共に、Redis の保存キーに使われます: `"doc:${NODE_ENV}:${LANG}"`

### 1. `sitemap.json` を用意する

以下の様な JSON ファイルが書き出せれば、ジェネレータは問いません。

ローカライズされている前提でできているので、一番上のキーはロケールで、その下に `title`, `description`, `body` を持ったハッシュの配列が入っています。

```json
{
  "en": [
    {
      "title": "Page 1",
      "description": "This is a sample page.",
      "body": "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
    }
  ],
  "ja": []
}
```

このファイルがデプロイされる URL を環境変数の `SITEMAP_URL` に設定します。

弊社では、[Middleman] と [middleman-i18n] を使って、ローカライズしています。

```rb
# sitemap.json.jbuilder
%i{en ja}.each do|lang|
  json.set! lang, sitemap.resources.select{|res|
    res.metadata[:options][:lang] == lang && res.ext == '.html'
  }
end
```

### 2. `TOKEN_SECRET` を設定する

前途の `POST /rebuild` エンドポイントに送信する `token` を生成するための秘密の文字列です。

## 検索ページ例

slim で書いています。

```slim
---
layout: full
---

- content_for :title do
  = "#{t 'search.title'}: "

.search-result data-api-base=ENV['DOC_SEARCH_API_BASE']
  h1
    = "#{t 'search.title'}: "
    q.search-tearm &nbsp;
  ul.entries
  p.no-result style='display:none' = t 'search.no_result'

coffee:
  unless m = document.location.search?.match /[\?&]q=([^&]+)/
    document.location.assign $('.brand a').attr 'href'
    return
  q = decodeURIComponent m[1]
  lang = $('html').attr 'lang'
  link = $('a[rel=alternate]')
  link.attr 'href', link.attr('href') + '?q=' + m[1]
  $('q.search-tearm').text q
  $('input.search-term').val q
  $.ajax
    url: $('.search-result').data('apiBase')
    data: { lang, q }
    xhrFields:
      withCredentials: yes
      crossDomain: yes
    success: (res) ->
      if res.length > 0
        for {url, title} in res
          $("""<li><a href="#{url}">#{title}</a></li>""").appendTo '.entries'
      else
        $('.entries').parent().find('.no-result').show()
```

## GitHub API v3 を直接使わなかった理由

### 1. 検索語は、単語一致であり、部分一致ではない

`JavaScript` という語句を見つけるために、`java` というキーワードは使えません。

[Search Code API] でサポートの有無を問い合わせたところ、将来、サポートするかもしれないが、確約はできない、とのことです。

### 2. プライベートリポジトリに対応していない

そもそも `access_token` 無しのリクエストでプライベートリポジトリを検索することはできません。

```bash
$ curl 'https://api.github.com/search/code?q=in:file%20java%20repo:kaizenplatform/super-secret-project&callback=foo'
```

```js
/**/foo({
  "meta": {
    "X-RateLimit-Limit": "10",
    "X-RateLimit-Remaining": "7",
    "X-RateLimit-Reset": "1425732905",
    "X-GitHub-Media-Type": "github.v3",
    "status": 422
  },
  "data": {
    "message": "Validation Failed",
    "errors": [
      {
        "message": "The listed users and repositories cannot be searched either because the resources do not exist or you do not have permission to view them.",
        "resource": "Search",
        "field": "q",
        "code": "invalid"
      }
    ],
    "documentation_url": "https://developer.github.com/v3/search/"
  }
})
```

[prev]: /2015/01/02/middleman-blog-search/
[repo]: https://github.com/kaizenplatform/doc-search-api
[middleman-i18n]: https://middlemanapp.com/jp/advanced/localization/
[Middleman]: https://middlemanapp.com/jp/
[README]: https://github.com/kaizenplatform/doc-search-api#readme
[SADD]: http://redis.io/commands/sadd
[SSCAN]: http://redis.io/commands/scan
[Search Code API]: https://developer.github.com/v3/search/#search-code
