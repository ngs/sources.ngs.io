---
title: Take cross browser screenshots with hubot-browserstack
description: I published a Hubot script to take cross browser screenshots with BrowserStack.
date: 2014-06-08 09:30
public: true
tags: hubot, browserstack
alternate: true
ogp:
  og:
    image:
      '': https://avatars0.githubusercontent.com/u/480938?s=460
      type: image/png
      width: 460
      height: 460
---

I published a [Hubot] script to take cross browser screenshots with [BrowserStack].

```
me > hubot screenshot me http://www.google.com/
hubot > Started generating screenshots in http://www.browserstack.com/screenshots/d804f186e460dc4f2a30849a9686c3a8c4276c21
```

To add this script run `npm install` command in your hubot directory.

```bash
npm install --save hubot-browserstack
```

and add `hubot-browserstack` to `external-scripts.json`

```json
["hubot-browserstack"]
```

For more details, visit GitHub repo: **[ngs/hubot-browserstack]**.

[Hubot]: https://hubot.github.com/
[BrowserStack]: http://www.browserstack.com/
[ngs/hubot-browserstack]: https://github.com/ngs/hubot-browserstack
