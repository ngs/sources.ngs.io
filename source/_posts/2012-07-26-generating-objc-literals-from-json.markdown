---
layout: post
title: "Generating Objective-C Literals from JSON"
date: 2012-07-26 12:00
comments: true
categories: [Test, Objective-C, node.js, JavaScript]
---

[The modern syntaxes](http://clang.llvm.org/docs/ObjectiveCLiterals.html) for NSDictionary, NSArray, NSNumber are supported from Xcode 4.4. To use this easily for testing, I customized JSON#stringify method ported from JSON2.js.

With node.js, the script can convert JSON from STDIN.

```bash
$ node Dictionary.js < test.js
# with cURL
$ curl 'http://itunes.apple.com/search?term=Path&entity=software' | node Dictionary.js
```

Also in browser, this works with stripping lines under `if(process)` scope.

```js
Dictionary.stringify({ a:1, b:"Hello", c:[1,2,3] }, null, "  ");
```

<!--more-->

{% gist 3180832 Dictionary.js %}