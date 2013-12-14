---
title: Snippets の Gist.scrippet で Private gist したい。
description: 深津さんの、エントリー " iOS開発におけるパターンによるオートマティズ  " を読んで、早速私も Amazon で購入しました。 ま 、第一 しか読んでいないので、感想は書けません。 こ...
date: 2011-02-12 05:00
public: true
tags: gist, github, ruby, scrippets, snippets
---

深津さんの、エントリー "[ iOS開発におけるパターンによるオートマティズム](http://fladdict.net/blog/2011/02/ios-automatism.html) " を読んで、早速私も Amazon で購入しました。

まだ、第一章しか読んでいないので、感想は書けません。

&nbsp;

このエントリーで、[Snippets](http://www.snippetsapp.com/) というソフトウェアに触れられていたので、ダウンロードして、試用しています。

今まで、同じ様な用途に、Evernote を使っていたのですが、こちらは、テキストデータに特化しているので、検索が早く、シンタックスハイライトも付いているので、気に入りました。

メニューバーから、[Scrippets](http://www.snippetsapp.com/extras/) という、拡張機能が選択でき、そこから、各種スニペット共有サイトにポストできたり、Placeholder (テンプレートタグみたいなもの) を置換したりできます。画像のものは、バンドルされているものです。

自作や、配布されているものを、新たに追加することも可能です。

![](2011-02-12-snippets-gist-bundle/capture1.png)

この中の、gist.github.com は、ブラウザでログインしている、いない、に関わらず、Anonymous として投稿されてしまいます。もちろん、Private gist も作れません。

なので、恐らく、この bundle の作者の、ベルギーの Simon さんという方のリポジトリを fork して、修正しました。

![](2011-02-12-snippets-gist-bundle/capture2.png)

オリジナルは、Gist Create API :&nbsp;[http://gist.github.com/api/v1/xml/new](http://gist.github.com/api/v1/xml/new) に、データを POST していたのですが、Private gist が仕様が公開されていないか、サポートされていないか、私が見過ごしたか、なので、[gist のコマンドラインツール](https://github.com/defunkt/gist)&nbsp;のコードを参考に、Gist の投稿ページ :&nbsp;[https://gist.github.com/gists](https://gist.github.com/gists) へポストする様に[変更しました](https://github.com/cimm/snippets-gist-scrippet/pull/1/files)。

一応、Pull request したので、もしかしたらバンドルされるかもしれませんが、もし、同じ悩みをかかえている人がいたら、私のリポジトリから、ソースを落として下さい。

[https://github.com/ngs/snippets-gist-scrippet](https://github.com/ngs/snippets-gist-scrippet)

インストールするとき、" 既に、Gist.scrippet はインストールされてるよ " と怒られるので、その前に、一度 Snippets を終了して、Snippets.app/SharedSupport/Scrippets/Gist.scrippet を、リネームするなり、削除するなりして下さい。

&nbsp;

Scrippets は、JavaScript / CSS / HTML / Ruby で実装されているので、簡単に作成できます。

API リファレンスが見当たらないので、仕様は手探りなのですが、Snippets.app/Contents/Resources/Scrippet.js に実装されているクラスのコードを読めば、JavaScript からアクセシブルな情報は、全て理解できます。

パッケージの構造は、[こちらのスライド ](http://www.slideshare.net/snippets/introducing-scrippets)の 28 ページ目で紹介されています。

また今度、自分オリジナルの Scrippet を作ってみたいと思います。