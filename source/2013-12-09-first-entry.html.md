---
title: ブログ構築しました。
description: middleman+GitHub Pages で再構築しました。
date: 2013-12-09
tags: blog, ruby, middleman
---

以前構築していたブログが、[Posterous](http://www.posterous.com/) 終了と共になくなってしまったので、やる気をなくしてしばらくブログを書いていませんでしたが、仕事で Middleman と出会い、シンプルさと拡張性が魅力的だったので、[GitHub Pages](http://pages.github.com) でホスティングしてもらう様、再構築しました。

とりあえず、ザクっとおなじみ [Bootstrap](http://getbootstrap.com) で。Bootstrap の無料テーマを配布している [Bootswatch](http://bootswatch.com) さんから、最新の [Yeti](http://bootswatch.com/yeti/) というテンプレートを拝借しました。

READMORE


### 移行計画

#### 英語ブログ

2012/04 から、OSS で殴り書いたり、tech-tips ものは、世界の人と共有したいので、英語でブログを書いています。 [ngs.io](http://ngs.io)

こちらは [Octopress](http://octopress.org) + [GitHub Pages](http://pages.github.com) を使っていますが、テンプレートが [liquid](http://liquidmarkup.org) 縛りだったり (今は haml も使える風？調べるのめんどくさい。)、使ってる [jekyll](http://jekyllrb.com) バージョンが古かったりで、こちらも卒業したく、日本語ブログのカスタマイズが終わったら、こちらも移行しようと思います。

エントリーは共通して Markdown なので、コピペして `git push origin master --force` などしてやれば、移行完了なので、いい時代ですね。

#### 旧ブログ

Posterous にあったエントリーなどは、ダンプして [GitHub Repo](https://github.com/ngs/posterous-backup) に突っ込んでおいたので、そのうちリカバーしようと思います。

### このブログの予定

Tech ネタもあると思いますが、あまり考えず、プログラミング、ガジェット、電子工作、ロードバイク、ランニング、旅行、ご飯など、趣味っぽいことも書いていきます。

### 近況

現在は [LittleApps Inc.](http://littleapp.jp/) での受注開発は行っておらず、 [KAIZEN platform Inc.](http://kaizenplatform.in) というベンチャー企業のメンバーとしてエンジニアをやっています。

しばらくバタバタしていますが、LittleApps Inc. 名義での、趣味で作ったソフトウェアたちは、落ち着いたらメンテ再開します。Issue とか上げてもらってますが、放ったらかしでごめんなさい。
