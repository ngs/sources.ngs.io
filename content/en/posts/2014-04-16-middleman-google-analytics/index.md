---
title: Universal Code support for middleman-google-analytics
description: I've sent a pull request to support Universal Code for middleman-google-analytics
date: 2014-04-16 10:00
public: true
tags: middleman, google analytics, pull request
alternate: true
---

As [Google announced][ga-blog], Universal Analytics became out of beta.

This blog is using [middleman-google-analytics] to embed Google Analytics code, so I need to paste the snippet or modify the extension to use Universal Analytics.

The extension helped me a lot, so I started improve that and sent pull requests.

READMORE

[danielbayerlein/middleman-google-analytics#15: **Universal code support**][pr15]

This update adds `google_analytics_universal_tag` to helper methods with existing `google_analytics_tag`.

```erb
<%= google_analytics_universal_tag %>
```

I also sent a pull request to add [unit tests] the project does not have yet. I enjoyed [Cucumber] coding <3

[danielbayerlein/middleman-google-analytics#14: **Added Cucumber tests**][pr14]

I hope that will merge happily, but if not, you can use the updates with referring my repos. (I do.)

```ruby
gem 'middleman-google-analytics', :github => 'ngs/middleman-google-analytics'
```

## Update 2014-04-17 05:40

Merged!

[![](merge.png)][pr15]

The version was bumped to [0.1.0] and released to [RubyGems].

```ruby
gem 'middleman-google-analytics', '~> 0.1.0'
```

[ga-blog]: http://analytics.blogspot.jp/2014/04/universal-analytics-out-of-beta-into.html
[middleman-google-analytics]: https://github.com/danielbayerlein/middleman-google-analytics/
[pr14]: https://github.com/danielbayerlein/middleman-google-analytics/pull/14
[pr15]: https://github.com/danielbayerlein/middleman-google-analytics/pull/15
[unit tests]: https://github.com/ngs/middleman-google-analytics/blob/c82d5deeb0e8295122b1ebcfbe8193c11980f462/features/helper.feature
[Cucumber]: http://cukes.info/
[0.1.0]: https://github.com/danielbayerlein/middleman-google-analytics/commit/c28a5fc1e0f72cd206ba5f8733c3655935501b9c
[RubyGems]: http://rubygems.org/gems/middleman-google-analytics
