---
title: "Generating Objective-C Literals from JSON"
date: 2012-07-26 12:00
public: true
tags: test, objective-c, node.js, javascript
alternate: true
---

[The modern syntaxes](http://clang.llvm.org/docs/ObjectiveCLiterals.html) for NSDictionary, NSArray, NSNumber are supported from Xcode 4.4. To use this easily for testing, I customized JSON#stringify method ported from JSON2.js.

With node.js, the script can convert JSON from STDIN.



Also in browser, this works with stripping lines under `if(process)` scope.




