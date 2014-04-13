---
layout: post
title: "Open Graph protocol tag helper for nanoc"
date: 2012-11-03 07:00
comments: true
categories: [nanoc, Ruby, Open Graph protocol]
---

I've created [Open Graph protocol](http://ogp.me/) tag helper for [nanoc](http://nanoc.stoneship.org/) to build my corporate site.

To use this helper:

1. Download [Ruby code](https://github.com/littleapps/littleapps.github.com/blob/source/lib/nanoc/helpers/og_tags.rb)
2. Place it to `lib/nanoc/helpers/` on your nanoc project.
3. Add ```require 'nanoc/helpers/og_tags'``` to `lib/default.rb`.
4. Now you can use `og_tag` helper in your templates.  
   For more details see the [spec](https://github.com/littleapps/littleapps.github.com/blob/source/spec/og_tags_spec.rb) or trace my [haml template](https://github.com/littleapps/littleapps.github.com/blob/source/layouts/default.haml).