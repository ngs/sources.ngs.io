---
title: middleman-ogp を作りました。
description: Middleman で OpenGraph Protocol タグを書き込む機能拡張を作りました
date: 2014-04-13 02:20
public: true
tags: middleman, opengraph
alternate: true
---

[以前欲しいと言っていた] Middleman で OpenGraph Protocol タグを簡単に扱えるプラグインが、待ってても出てこないので、自分で作りました。

[ngs/middleman-ogp on GitHub][middleman-ogp]


Gemfile に以下を追加して、使えます。

```ruby
gem 'middleman-ogp'
```

READMORE

config.rb に以下の項目を追加してアクティベートします。



レイアウトに以下の様にタグを追記します。



各ページのデータに含まれる `ogp` 配下の項目とマージされます。



こんな感じの `meta` タグが出力されます。



[middleman-ogp]: https://github.com/ngs/middleman-ogp
[以前欲しいと言っていた]: https://ja.ngs.io/2013/12/09/middleman-opengraph/
