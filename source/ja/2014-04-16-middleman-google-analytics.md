---
title: middleman-google-analytics の Universal Code 対応
description: middleman-google-analytics の Universal Code 対応させる Pull Request を送りました。
date: 2014-04-16 10:00
public: true
tags: middleman, google analytics, pull request
---

先日 [Google から発表があった][ga-blog]通り、ユニバーサル アナリティクスが正式リリースされました。

[このブログ][this blog] は [middleman-google-analytics] を使って Google Analytics タグを埋め込んでいるので、、ユニバーサル アナリティクス対応するには、直接コードをレイアウトに書くか、機能拡張を改修する必要がありました。

折角、今までお世話になってきたので、改修をして Pull Request を送りました。

READMORE

[danielbayerlein/middleman-google-analytics#15: **Universal code support**][pr15]

この改修で今まで使っていた `google_analytics_tag` に加えて、`google_analytics_universal_tag` ヘルパーが追加されます。

```erb
<%= google_analytics_universal_tag %>
```

ついでに、今までこのプロジェクトは Unit Test がなかったみたいなので、[テストコード]を追加して、別途 Pull Request を送りました。[Cucumber] 楽しいですね。

[danielbayerlein/middleman-google-analytics#14: **Added Cucumber tests**][pr14]

無事採用されると良いですが、最悪リジェクトされたとしても、Gemfile で直接僕のリポジトリを参照してもらえたら、使えます。(僕はそうしてます。)

```ruby
gem 'middleman-google-analytics', :github => 'ngs/middleman-google-analytics', :ref => 'universal-code'
```


[ga-blog]: http://analytics-ja.blogspot.jp/2014/04/universal-analytics.html
[middleman-google-analytics]: https://github.com/danielbayerlein/middleman-google-analytics/
[this blog]: http://ja.ngs.io/
[pr14]: https://github.com/danielbayerlein/middleman-google-analytics/pull/14
[pr15]: https://github.com/danielbayerlein/middleman-google-analytics/pull/15
[テストコード]: https://github.com/ngs/middleman-google-analytics/blob/c82d5deeb0e8295122b1ebcfbe8193c11980f462/features/helper.feature
[Cucumber]: http://cukes.info/
