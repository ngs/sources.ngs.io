---
title: "Generating Objective-C Literals from JSON"
date: 2012-07-26 12:00
public: true
tags: test, objective-c, node.js, javascript
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

READMORE

<script src="https://gist.github.com/ngs/3180832.js?file=Dictionary.js"></script>
