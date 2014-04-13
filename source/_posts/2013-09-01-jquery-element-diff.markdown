---
layout: post
title: "Generating JavaScript code to arrange elements to be same with specified HTML or element using jQuery Element Diff"
date: 2013-09-01 12:00
comments: true
categories: [JavaScript, Generator, Element, Diff, jQuery, Plugin, npm, bower]
---

[jQuery Element Diff Plugin](https://github.com/ngs/jquery-elementDiff) is a plugin to generate JavaScript code to arrange elements to be same.

```html
<div id="sample-text1">
  Lorem ipsum
  <span class="span1">dolor</span>
  <span class="span2">sit</span>
  <span class="span3">amet</span>,
  <span class="span4">consectetur</span>
  <span class="span5">adipiscing</span>
  <span class="span6">elit</span>.
</div>
<div id="sample-text2">
  Lorem ipsum
  <span class="span1" id="dolor">dolor</span>
  <span class="span2">sit!</span>
  <b class="span3">amet</b>,
  <span class="span5">adipiscing</span>
  <span class="span6">elit</span>.
</div>
```

```javascript
$("#sample-text1").getElementDiff($("#sample-text2"));
// [
//    "$(\"#sample-text1 > :eq(0)\").attr({\"id\":\"dolor\"})",
//    "$(\"#sample-text1 > :eq(1)\").html(\"sit!\")",
//    "$(\"#sample-text1 > :eq(2)\").replaceWith(\"<b class=\\\"span3\\\">amet</b>\")",
//    "$(\"#sample-text1 > :eq(3)\").attr({\"class\":\"span5\"}).html(\"adipiscing\")",
//    "$(\"#sample-text1 > :eq(4)\").attr({\"class\":\"span6\"}).html(\"elit\")",
//    "$(\"#sample-text1 > :eq(5)\").remove()",
//    "$(\"#sample-text1\").attr({\"id\":\"sample-text2\"})"
// ]
```

[Download](https://github.com/ngs/jquery-elementDiff/archive/master.zip) (contained in `dist` folder) or clone [GitHub](https://github.com/ngs/jquery-elementDiff) repository.

Also available on [npm](https://npmjs.org/package/jquery-element-diff):
```bash
$ npm install jquery-element-diff
```

or [bower](http://bower.io/):
```bash
$ bower install jquery-elementDiff
```
