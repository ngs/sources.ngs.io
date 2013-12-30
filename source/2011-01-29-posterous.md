---
title: ホスティング環境を整理しました。
description: ブログや Wiki 、Subversion リポジトリ、友達のサイトなど、相乗りで 使えるネット の VPS に構築していましたが、バージョン管理を Git に移行したり、同じ Apache に、モジュールを共存さ...
date: 2011-01-29 00:00
public: true
tags: blog, dreamhost, facebook, github, hosting, infrastructure, littleapps, posterous, subversion
---

ブログや Wiki 、Subversion リポジトリ、友達のサイトなど、相乗りで 使えるネット の VPS に構築していましたが、バージョン管理を Git に移行したり、同じ Apache に、モジュールを共存させすぎたのが原因で、負荷が高かったので、メンテナンスが億劫になり、それぞれウェブサービスに移行しました。

READMORE

#### 個人/会社サイトホーム

[GitHub Pages](http://pages.github.com/)

#### Wiki

GitHub Wiki / gist にバックアップ、今後は gist に集約させます。 

#### 個人ブログ

過去のものは [Dreamhost](http://dreamhost.com/) で、[blog1.ngsdev.org](http://blog1.ngsdev.org/) に移行。  
今後は この [Posterous](http://posterous.com/) に気が向いたら書いていきます。 

#### バージョン管理

Subversion は、一旦 Repository root を tarball にして、Dreamhost に。  
終っていない / メンテしている案件は、gitsvn で、Git リポジトリに変換。それ以外は放置です。

これからは、Dreamhost にリモートリポジトリを作っていきます。容量無制限なので安心です。

( ちなみに、iTunes や動画などの大きなデータのバックアップにも使っています。 )

また、新たに[会社のプロダクトサイト](http://littleapps.jp/)を開設しました。

こちらも Posterous です。 [http://littleapps.jp/](http://littleapps.jp/)

ソフトウェアのリリース / アップデート情報などを流していきます。

それに連動する [Facebook Page](http://www.facebook.com/littleapps.jp) も作成したので、よかったら Like ! ボタンをクリックして下さい。

現時点では、メンバーが 25 人に満たないので、Custom Username を設定できていません。( 参考: [Facebook Help Center](http://www.facebook.com/help/?page=900) )
