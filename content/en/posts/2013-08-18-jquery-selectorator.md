---
title: ""Generating unique selector with jQuery Selectorator""
date: 2013-08-18T12:00:00+09:00
public: true
tags: ["javascript", "selector", "jquery", "plugin", "npm", "bower"]
---

[jQuery Selectorator Plugin][GitHub] is a plugin to generate unique selector from jQuery object.

```javascript
$('element').getSelector()
```

Set `options.ignore` to ignore classes", "ids", "names:

```javascript
$('element').getSelector({ ignore: { classes: ['ui-droppable'] } })
```

<!--more-->

[Download] (contained in `dist` folder) or clone [GitHub] repository.

Also available on [npm]:

```bash
$ npm install jquery-selectorator
```

or [bower]:

```bash
$ bower install jquery-selectorator
```

Selectorator is inspired by [Optimizely].

[GitHub]: https://github.com/ngs/jquery-selectorator
[Download]: https://github.com/ngs/jquery-selectorator/archive/master.zip
[npm]: https://npmjs.org/package/jquery-selectorator
[bower]: http://bower.io/
[Optimizely]: https://www.optimizely.com/
