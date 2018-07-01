---
title: "middleman-blog で手っ取り早く絵文字対応をする:full_moon_with_face:"
description: "middleman-blog で絵文字を使おうとすると、既存のプラグインが上手く組み込めなかったので、手っ取り早く、自分で拡張しました:hammer:"
date: 2015-04-13 20:30
public: true
tags: middleman, blog, emoji, github
alternate: false
ogp:
  og:
    image:
      '': 2015-04-13-middleman-gemoji/emojis.png
      type: image/png
      width: 1400
      height: 1020
---

[middleman-blog] でブログを書いていて、絵文字対応をしようと、既存の Middleman プラグイン: [middleman-emoji], [middleman-gemoji] を試してみたのですが、どちらも、現在の [middleman-blog] 安定版: v3.5.3 から簡単に組み込めませんでした。(依存している Middleman Core バージョンが 3.3 になっていたのを 3.2 に緩めたりもしてみました。)

さらに、Middleman を 3.3 にアップデートしてみたのですが、既存のエントリーに互換性がなく、エラーが起き、ビルドできず、解決するのに工数を要しそうだったので、自分で拡張することにしました。

READMORE

## やったこと

- Markdown 本文で `:emoji_name:` の様な、コロンで囲われた部分を `<img>` タグで、GitHub の CDN にホスティングされている Emoji を表示する様置換する。
- View から `emojify(content, mode)` ヘルパーを使える様にする
  - `mode == :row` のとき、[Unicode 標準絵文字] は Unicode 絵文字で、それ以外は空白を返す様にする

## gemoji

絵文字の辞書は、GitHub が公開している、[gemoji] を使います。

```rb
gem 'gemoji', '~> 2.1'
```

### lib/emoji_helper.rb

Helper は、[gemoji の README] にあるものを流用します。

```rb
module EmojiHelper
  def emojify(content, mode = nil)
    content.to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        if mode == :raw
          emoji.raw
        else
          %(<img alt="#$1" src="https://assets-cdn.github.com/images/icons/emoji/#{emoji.image_filename}?v5" style="width: 1em; vertical-align:middle" class="gemoji">)
        end
      else
        match
      end
    end if content.present?
  end
end
```

## Markdown 本文の置換

元々 [Redcarpet レンダラー] を使用していたものを、`Middleman::Renderers::RedcarpetTemplate` をサブクラス化した、カスタムモジュールを使うことで、Markdown のレンダリングを上書きします。

### lib/middleman/renderers/custom.rb

```rb
require 'middleman-core/renderers/redcarpet'
require 'gemoji'
module Middleman
  module Renderers
    class CustomTemplate < RedcarpetTemplate; end
    module CustomRenderer
      include ::Redcarpet::Render::SmartyPants
      include ::EmojiHelper
      def preprocess(full_document)
        emojify full_document
      end
    end
  end
end
::Middleman::Renderers::MiddlemanRedcarpetHTML.send :include, ::Middleman::Renderers::CustomRenderer
```

### config.rb

```rb
require './lib/middleman/emoji_helper'
require './lib/middleman/renderers/custom'

set :markdown_engine, :custom
set :markdown_engine_prefix, ::Middleman::Renderers
set :markdown, :fenced_code_blocks => true, :smartypants => true,
  :autolink => true, :tables => true, :with_toc_data => true

ready do
  ::Middleman::Renderers::MiddlemanRedcarpetHTML.middleman_app = self
end
helpers do
  include EmojiHelper
end
```

## `<meta>`, `<title>` 要素の置換

`<meta>`, `<title>` 要素 は `<img>` タグを含めることができないので、`emojify` ヘルパーメソッドの2番目の引数を `:raw` にして、Unicode の絵文字をそのまま置換します。

```slim
title = emojify current_article.title, :raw
```

![](2015-04-13-middleman-gemoji/unicode-replaced.png)

[Unicode 標準絵文字] でない場合には、空白に置換します。

## 無事置換できました :ok_hand:

![](2015-04-13-middleman-gemoji/emojis.png)

[middleman-blog]: https://github.com/middleman/middleman-blogA
[middleman-emoji]: https://github.com/stny/middleman-emoji
[middleman-gemoji]: https://github.com/yterajima/middleman-gemoji
[Unicode 標準絵文字]: http://ja.wikipedia.org/wiki/Unicode6.0%E3%81%AE%E6%90%BA%E5%B8%AF%E9%9B%BB%E8%A9%B1%E3%81%AE%E7%B5%B5%E6%96%87%E5%AD%97%E3%81%AE%E4%B8%80%E8%A6%A7
[gemoji]: https://github.com/github/gemoji
[gemoji の README]: https://github.com/github/gemoji#example-rails-helper
[Redcarpet レンダラー]: https://github.com/middleman/middleman/blob/v3-stable/middleman-core/lib/middleman-core/renderers/redcarpet.rb
