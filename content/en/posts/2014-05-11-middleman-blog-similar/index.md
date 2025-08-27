---
title: Similar Articles on middleman-blog
description: I created a middleman-blog extension to lookup similar articles.
date: 2014-05-11 12:00
public: true
tags: middleman, blog, similarity, levenshtein, tf-idf
alternate: true
---

I created a [middleman-blog] extension to lookup similar articles.

View **[middleman-blog-similar on GitHub][middleman-blog-similar]**.





You can retrieve similar articles from `similar_articles` helper method or `Middleman::Blog::BlogArticle#similar_articles` instance method.

READMORE

Currently this extension supports similarity engines: [levenshtein-ffi], [levenshtein] and [damerau-levenshtein].

However, I think those are bit low accuracy, so I'm tring to create engines with [tf-idf-similarity] library.

Pull request: **[[wip] tf*idf support #2][pr]**

You will be able to choose similarity engines like the below in your `config.rb`:



[middleman-blog]: https://github.com/middleman/middleman-blog
[middleman-blog-similar]: https://github.com/ngs/middleman-blog-similar
[levenshtein-ffi]: https://github.com/dbalatero/levenshtein-ffi
[levenshtein]: https://github.com/schuyler/levenshtein
[damerau-levenshtein]: https://github.com/GlobalNamesArchitecture/damerau-levenshtein
[tf-idf-similarity]: https://github.com/opennorth/tf-idf-similarity
[pr]: https://github.com/ngs/middleman-blog-similar/pull/2
