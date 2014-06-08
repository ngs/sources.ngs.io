---
title: hubot-browserstack でクロスブラウザのスクリーンショットを撮影する
description: Hubot にお願いして、BrowserStack でクロスブラウザのスクリーンショットを撮ってもらうスクリプトを公開しました。
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

[Hubot] にお願いして、[BrowserStack] でクロスブラウザのスクリーンショットを撮ってもらうスクリプトを公開しました。

```
me > hubot screenshot me http://www.google.com/
hubot > Started generating screenshots in http://www.browserstack.com/screenshots/d804f186e460dc4f2a30849a9686c3a8c4276c21
```

このスクリプトを追加するには `npm install` コマンドを [Hubot] ディレクトリで実行して、

```bash
npm install --save hubot-browserstack
```

`hubot-browserstack` を `external-scripts.json` に追加してください。

```json
["hubot-browserstack"]
```

詳しくは GitHub リポジトリを参照してください: **[ngs/hubot-browserstack]**.

[Hubot]: https://hubot.github.com/
[BrowserStack]: http://www.browserstack.com/
[ngs/hubot-browserstack]: https://github.com/ngs/hubot-browserstack
