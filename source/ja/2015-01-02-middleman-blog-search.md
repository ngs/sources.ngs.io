---
title: "Middleman+GitHub で構築したサイトの検索画面を作る"
description: "Middleman と GitHub で構築したサイトで、検索画面を作る方法"
date: 2015-01-02 07:40
public: true
tags: middleman, github, api, seo, google
alternate: false
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2015-01-02-middleman-blog-search/screen1.png
      type: image/jpeg
      width: 992
      height: 525
---

このブログは [Middleman] と　[GitHub Pages] で構築しています。

[GitHub Pages] は静的な資材をホスティングする機能しかないため、Movable Type でいうところの、`mt-search.cgi` みたいな、動的な検索画面は作れない制約があります。

そこで、[GitHub API v3] を使って JavaScript で実装することにしました。

実際の動作は、サイドバー (モバイル画面では下部) にある、検索窓から、適当な文字列で検索してみて下さい。(例: [Hubot](/search/?q=Hubot))

READMORE

## 実装コード

たった 34 行です。 **[search.slim]** on [ngs/sources.ngs.io]

個人ブログで、規模が小さいので、多少富豪的な実装になっています。

## Search Code API

検索には GitHub の [Search Code API] を使っています。検索に使える修飾子は Advanced Search と共通しています。

[Searching code on GitHub Help]

Search term `q` に URI エンコードされた検索文字列と、ブログリポジトリ、記事資材を保存しているパスを指定します。

`per_page` には `100` を指定します。

```coffee
"https://api.github.com/search/code?q=#{ encodeURIComponent q }+repo:ngs/sources.ngs.io+path:/source/#{lang}/&per_page=100"
```

## サイトマップ・リソース

当たり前ですが、[Search Code API] は、記事のタイトル・日付など、Middleman 固有のデータ返せないので、[サイトマップ・リソース]のデータをパスをキーにするハッシュにぶら下げておきます。

```slim
ruby:
  sitemap = {}
  blog.articles.each{|a|
    sitemap[a.url] = a.data.merge url: a.url
  }
javascript:
  sitemap = #{sitemap.to_json}
```

API のコールバックの中で、上記のデータと付け合わせて、テンプレート内でイテレートするコレクションを集めます。

```coffee
items = _.map res?.items, ({name}) ->
  m = name.match /^(\d{4})\-(\d{2})\-(\d{2})\-(.+)\.md(?:\.erb)?/
  permalink = "/#{m[1]}/#{m[2]}/#{m[3]}/#{m[4]}/"
  sitemap[permalink]
```

## SEO 問題

![](2015-01-02-middleman-blog-search/screen1.png)

今回はウェブ検索に引っかかる必要がないので、対策していませんが、[GitHub API v3] は robots.txt の制約により、クローラーのアクセスを許可していません。

(上は、Google ウェブマスターツールの [Fetch as Google] で確認した画面です。)

https://api.github.com/robots.txt

もし、Single Page Application などで活用し、SEO も行いたいのであれば、[Heroku] に迂回用のアプリを作るなどして対応する必要があります。

[GitHub API v3]: https://developer.github.com/v3/
[GitHub Pages]: https://pages.github.com/
[Middleman]: http://middlemanapp.com/
[underscore.js]: http://underscorejs.org/
[Search Code API]: https://developer.github.com/v3/search/#search-code
[サイトマップ・リソース]: http://middlemanapp.com/jp/advanced/sitemap/#%E3%82%B5%E3%82%A4%E3%83%88%E3%83%9E%E3%83%83%E3%83%97%E3%81%AE%E3%83%AA%E3%82%BD%E3%83%BC%E3%82%B9
[search.slim]: https://github.com/ngs/sources.ngs.io/blob/master/source/search.slim
[ngs/sources.ngs.io]: https://github.com/ngs/sources.ngs.io/
[Searching code on GitHub Help]: https://help.github.com/articles/searching-code/
[Heroku]: https://www.heroku.com/
[Fetch as Google]: https://support.google.com/webmasters/answer/6066467?hl=ja
