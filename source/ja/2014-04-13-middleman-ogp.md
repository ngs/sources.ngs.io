---
title: middleman-ogp を作りました。
description: Middleman で OpenGraph Protocol タグを書き込む機能拡張を作りました
date: 2014-04-13 02:20
public: true
tags: middleman, opengraph
alternate: true
---

[以前欲しいと言っていた][prev-entry] Middleman で OpenGraph Protocol タグを簡単に扱えるプラグインが、待ってても出てこないので、自分で作りました。

[ngs/middleman-ogp on GitHub][middleman-ogp]


Gemfile に以下を追加して、使えます。

```ruby
gem 'middleman-ogp'
```

READMORE

config.rb に以下の項目を追加してアクティベートします。

```ruby
activate :ogp do |ogp|
  ## デフォルトのプロパティー
  ogp.namespaces = {
    fb: data.ogp.fb,
    # from data/ogp/fb.yml
    og: data.ogp.og
    # from data/ogp/og.yml
  }
  ## og:url の起点となる URL
  og.base_url = 'http://mysite.tld/'
  ## article:published_time と article:tag を自動で埋めてくれる。
  ogp.blog = true
end
```

レイアウトに以下の様にタグを追記します。

```
html
  head
    meta charset="utf-8"
    title= data.page.title
    - ogp_tags do|name, value|
      meta property=name content=value

  body
    .container
      = yield
```

各ページのデータに含まれる `ogp` 配下の項目とマージされます。

```yaml
---
title: My First Fixture.
description: This is my fixture Middleman article.
ogp:
  og:
    image:
      '': http://mydomain.tld/path/to/fbimage.png
      secure_url: https://secure.mydomain.tld/path/to/fbimage.png
      type: image/png
      width: 400
      height: 300
    locale:
      '': en_us
      alternate:
        - ja_jp
        - zh_tw
---

Hello
=====

This is the __content__
```

こんな感じの `meta` タグが出力されます。

```html
<meta content='250606621791116' property='fb:app_id'>
<meta content='http://mysite.tld/page1.html' property='og:url'>
<meta content='My First Fixture.' property='og:title'>
<meta content='This is my fixture Middleman article.' property='og:description'>
<meta content='http://mydomain.tld/path/to/fbimage.png' property='og:image'>
<meta content='https://secure.mydomain.tld/path/to/fbimage.png' property='og:image:secure_url'>
<meta content='image/png' property='og:image:type'>
<meta content='400' property='og:image:width'>
<meta content='300' property='og:image:height'>
<meta content='en_us' property='og:locale'>
<meta content='ja_jp' property='og:locale:alternate'>
<meta content='zh_tw' property='og:locale:alternate'>
```

[middleman-ogp]: https://github.com/ngs/middleman-ogp
[prev-entry]: http://ja.ngs.io/2013/12/09/middleman-opengraph/
