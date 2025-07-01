---
title: "middleman-ogp"
description: "Released an OpenGraph Protocol helper extension for Middleman."
date: 2014-04-13T02:20:00+09:00
public: true
tags: ["middleman", "opengraph"]
alternate: true
---

I released an OpenGraph Protocol helper extension for Middleman.

[ngs/middleman-ogp on GitHub][middleman-ogp]


In your Gemfile

```ruby
gem 'middleman-ogp'
```

<!--more-->

Activate the extension with adding this snippet in config.rb.

{{< partial "2014-04-13-middleman-ogp/01.config.rb.html.md" >}}

Add `ogp_tags` method and write `<meta>` tag in the block.

{{< partial "2014-04-13-middleman-ogp/02.layout.slim.html.md" >}}

Page data (root key is `ogp`) will be merged to the default properties.

{{< partial "2014-04-13-middleman-ogp/03.metadata.yml.html.md" >}}

Outputs `<meta>` tags like this.

{{< partial "2014-04-13-middleman-ogp/04.metatag.html.html.md" >}}

[middleman-ogp]: https://github.com/ngs/middleman-ogp
