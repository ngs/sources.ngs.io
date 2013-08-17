---
layout: post
title: "Generating unique selector with jQuery Selectorator"
date: 2013-08-18 12:00
comments: true
categories: [JavaScript, Selector, jQuery, Plugin, npm]
---

[jQuery Selectorator Plugin](https://github.com/ngs/jquery-selectorator) is a plugin to generate unique selector from jQuery object.

```javascript
$('element').getSelector()
```

Set `options.ignore` to ignore classes, ids, names:

```javascript
$('element').getSelector({ ignore: { classes: ['ui-droppable'] } })
```

[Download](https://github.com/ngs/jquery-selectorator/archive/master.zip) (contained in `dist` folder) or clone [GitHub](https://github.com/ngs/jquery-selectorator) repository.

Also available on [npm](https://npmjs.org/package/jquery-selectorator):
```bash
$ npm install jquery-selectorator
```

or [bower](http://bower.io/):
```bash
$ bower install jquery-selectorator
```

Selectorator is inspired by [Optimizely](https://www.optimizely.com/).
