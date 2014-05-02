---
title: MacOS XでAIRアプリがクラッシュする件
description: BUILT NY Kindle Slim Folio Cover
date: 2009-01-17 01:00
public: true
tags: macosx, adobeair, simbl
alternate: false
---

AdobeAIR のバージョンを 1.5 にアップデートしてから、initialWindow/content に HTML を指定してあるアプリや、HTMLLoader でウェブページを表示しているものが、MacOS X でクラッシュし、全く立ち上がらない状態でした。

READMORE

[adl で立ち上げても](https://code.google.com/p/abroadair/source/browse/trunk/tools/launch.sh)、以下のように出力され、adl はクラッシュします。

```bash
macpro:tools ngs$ ./launch.sh

2009-01-17 01:00:00.548 adl[451:10b] *** +[WebFontCache fontWithFamily:traits:weight:size:]: unrecognized selector sent to class 0xa0796480
2009-01-17 01:00:00.549 adl[451:10b] *** NSTimer ignoring exception '*** +[WebFontCache fontWithFamily:traits:weight:size:]: unrecognized selector sent to class 0xa0796480' that raised during firing of timer with target 0x13e140 and selector '_playerTimerAction:'
2009-01-17 01:00:00.553 adl[451:10b] *** +[WebFontCache fontWithFamily:traits:weight:size:]: unrecognized selector sent to class 0xa0796480
2009-01-17 01:00:00.553 adl[451:10b] *** NSTimer ignoring exception '*** +[WebFontCache fontWithFamily:traits:weight:size:]: unrecognized selector sent to class 0xa0796480' that raised during firing of timer with target 0x13e140 and selector '_playerTimerAction:'
./launch.sh: line 2:   451 Bus error               adl application.xml ../src
```

結局、原因となっていたのは、[Safari AdBlock](http://safariadblock.sourceforge.net/) と [Greasekit](http://8-p.info/greasekit/) で、[Safari Microformats Plugin](http://zappatic.net/safarimicroformats/) は、イキママで OK でした。

是非、Mac OS X ユーザーの方で AIR アプリが落ちて困っている方は、まず、SIMBL を疑ってみてください。

\# SIMBLに影響を受けないように AIR ランタイムを開発してほしいのが本命ですが。
