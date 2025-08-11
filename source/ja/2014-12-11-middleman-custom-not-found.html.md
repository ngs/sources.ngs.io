---
title: Middleman のプレビューサーバーの 404 Not Found 画面をカスタマイズする
description: Middleman のプレビューサーバーの 404 Not Found 画面をカスタマイズする必要があったので、機能拡張を書きました。
date: 2014-12-11 00:00
public: true
tags: middleman, preview, angularjs, s3, aws
alternate: false
ogp:
  og:
    image:
      '': 2014-12-11-middleman-custom-not-found/not-found.png
      type: image/png
      width: 992
      height: 525
---

![](2014-12-11-middleman-custom-not-found/not-found.png)

現在、開発している [AngularJS] アプリケーションは、土台を [Middleman] で作り、[Amazon S3] の [静的ウェブサイトホスティング] を使って公開する仕組みになっており、エラーページにロジックを書く必要がありました。 (後述します)

[Middleman] の[プレビューサーバー]の 404 Not Found 画面は、上記の画像の様なそっけないもので、ライブラリにべた書きされています。

参照: [middleman-core/core_extensions/request.rb]

これでは、エラーページの確認が難しいので、この 404 画面をカスタマイズする機能拡張を書きました。

READMORE

## config.rb (抜粋)

```rb
require './lib/middleman/extensions/custom_not_found'
activate :custom_not_found
```


## lib/middleman/extensions/custom\_not\_found.rb

```rb
require 'middleman-core'

class CustomNotFound < ::Middleman::Extension
  option :error_page, 'error.html', 'Path for error page. `error.html` by default.'

  def initialize(app, options_hash={}, &block)
    super
    error_page = options.error_page
    app.before do
      path = ::Middleman::Util.normalize_path req.path
      path = 'index.html' if path.empty?
      sitemap.ensure_resource_list_updated!
      unless sitemap.find_resource_by_destination_path path
        paths = sitemap.instance_variable_get :@_lookup_by_destination_path
        paths[path] = paths[error_page]
      end
      true
    end
  end
end

::Middleman::Extensions.register(:custom_not_found, CustomNotFound)
```


## error_page.html.slim

Slim テンプレートには以下の様な JavaScript が記述されています。

```slim
javascript:
  document.location.href = "#{config[:http_prefix]}#" + document.location.pathname
```


HTML レンダリング結果は以下の様になります。

```html
<script type="text/javascript">
  document.location.href = "/#" + document.location.pathname
</script>
```


## S3 設定

![](2014-12-11-middleman-custom-not-found/s3console.png)

この `error.html` を [Amazon S3] のコンソール上でエラーページとして設定しておくことで、[HTML5 mode] の [AngularJS] アプリケーションで、リロードされた場合も、`/index.html` に実装されている本体に転送し、リロード前の状態を復元することが可能になります。


[HTML5 mode]: https://docs.angularjs.org/guide/$location#hashbang-and-html5-modes
[Middleman]: http://middlemanapp.com/jp/
[middleman-core/core_extensions/request.rb]: https://github.com/middleman/middleman/blob/v3.3.7/middleman-core/lib/middleman-core/core_extensions/request.rb#L284
[AngularJS]: https://angularjs.org
[プレビューサーバー]: http://middlemanapp.com/jp/basics/getting-started/#開発サイクル-(middleman-server)
[Amazon S3]: http://aws.amazon.com/jp/s3/
[静的ウェブサイトホスティング]: http://aws.amazon.com/jp/websites/
