---
title: middleman-ogp
description: Released an OpenGraph Protocol helper extension for Middleman.
date: 2014-04-13 02:20
public: true
tags: middleman, opengraph
---

I released an OpenGraph Protocol helper extension for Middleman.

[ngs/middleman-ogp on GitHub][middleman-ogp]


In your Gemfile

```ruby
gem 'middleman-ogp'
```

READMORE

Activate the extension with adding this snippet in config.rb.

```ruby
activate :ogp do |ogp|
  ## Default Properties
  ogp.namespaces = {
    fb: data.ogp.fb,
    # from data/ogp/fb.yml
    og: data.ogp.og
    # from data/ogp/og.yml
  }
  ## Base URL for og:url
  og.base_url = 'http://mysite.tld/'
  ## Fills article:published_time and article:tag automatically.
  ogp.blog = true
end
```

Add `ogp_tags` method and write `<meta>` tag in the block.

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

Page data (root key is `ogp`) will be merged to the default properties.

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

Outputs `<meta>` tags like this.

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
