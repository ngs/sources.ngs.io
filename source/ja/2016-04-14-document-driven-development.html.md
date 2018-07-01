---
title: "ドキュメントを起点としたコミュニケーションで進める Oneteam の開発"
description: "04/13 に開催した、Collaboration Hack Meetup で発表した、ドキュメントを起点としたコミュニケーションで進める Oneteam の開発について"
date: 2016-04-14 15:00
public: true
tags: oneteam, project management, meetup
alternate: false
ogp:
  og:
    image:
      '': 2016-04-14-document-driven-development/1.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2016-04-14-document-driven-development/1.jpg)

2016-04-13 に、現場主導の業務改善をテーマとした [Collaboration Hack Meetup] を [Loco Partners 社] と 弊社 [Oneteam Inc.] 共同で開催しました。

その会で発表した、_ドキュメントを起点としたコミュニケーションで進める Oneteam の開発_ について詳しく、改めてエントリーにします。

発表資料は、このエントリーの[末尾]に埋め込んでいます。　

READMORE

## Daily Standup が長い問題

![](2016-04-14-document-driven-development/ds.jpg)

自分が働いている [Oneteam Inc.] の開発チームでは、**Daily Standup** と呼ばれるミーティングを毎朝全員で行い、お互いの状況と優先順位の差配、相談事などを行っています。

自分が[参画]してから暫くの間、主な参加者はプロダクトマネージャー1名とエンジニア3名の小さなチームでした。

その全員が現在進行中の案件の状況を共有し、将来とりかかるべき、未着手タスクについて議論しても、カレンダーにスケジュールされている1時間以内、大体40分以内でミーティングを終わらせることができました。

嬉しいことに、今年に入って、1名のデザイナーと1名のエンジニアを仲間に向かい入れることができ、開発スピードがアップし、同時に取り掛かれる案件が増えてきました。おおよそ人数+αぐらいだったものが、現在では約2倍になったイメージです。

そのため、共有すべきタスクが増えて、一つ一つ丁寧に確認していては、スケジュールどおりに会議を終わらせることができず、業務時間も圧迫されます。

## リンク先を参照するだけの Daily Standup

![](2016-04-14-document-driven-development/doc.jpg)

その問題を解決するため、元々、我々の製品 [Oneteam] 上に任意で書いていた Design Doc という設計書を、プロジェクト毎に作成することを必須化し、タスク管理をその中で行う運用に変更しました。

元々とっていた Daily Standup の議事録は廃止し、事前に _Product Development Daily Summary_ なる Topic を Oneteam 上に作成し、そこに各プロジェクトの Design Doc へのリンクをステータスに分けて貼り付けます。

ステータスは、以下の様に定義しています。

- **Shipped Yesterday**: 昨日、完了したタスク。
- **Shipping**: 実装は済んでいるが、動作確認済、Apple のレビュー待ちなどの理由でまだ完了できていないタスク。
- **Under Development**: 現在実装作業中の機能。
- **Backlog**: 未着手のタスク。

**Under Development** ステータスにする (= 案件着手) ためには、Design Doc を必須とします。

後述のとおり、一定のフォーマットにそって記載しおり、タブで全ての Design Doc のリンク先を開いて、流れ作業的にそれらをなぞっていくだけで、各自状況を口頭で説明する必要なく状況の共有が完了します。

また、我々の Oneteam のリアルタイムメッセージ機能で細かいやりとりや、決議事項をまとめているので、元々そのプロジェクトに参加していなかった人でも、プロジェクトの経緯と結果を把握することができます。

## Design Doc の構成

Design Doc は以下の様な形式で統一して記載することで、見なおした時の閲覧コストを減らします。

### Issue and Background / 課題と背景

```
- XX が XX をしているとき、XX の様な経験をしている。
- 本製品としては、XX な経験が理想的なので、それを解決したい。
```

利用者の目線で、理解しやすい文章を書くことを意識します。

### Goal / 目標

```
XX にとって、YY をしているとき、ZZ な経験を提供できるように改修する。
```

ここには、プロジェクトの目的を書きます。実現したいことだけを書き、解決策については記載しません。

実装することが目的になってはいけないからです。

### Solutions / 実現方法

```
xxxx テーブルに yyyy カラムを追加
```

ここには上記の様な、具体的な実装方法を書きます。

閲覧するのは、全員エンジニアではないので、情報が多くなりすぎないことを心がけます。

もし API エンドポイントのパラメータ一覧や、新規テーブル追加など、詳細な設計書が必要な場合には、別途 GitHub 上での Pull Request コメントや、ソースコードと一緒に管理している、Markdown ドキュメントに設計を記載します。

### Tasks

ここには、実行すべきタスクをステータスに分けて列挙します。Daily Standup では、主にこの項目を確認します。

弊社の場合、開発 -> ステージング -> 本番、といった流れでデプロイをしていき、それぞれのステージで動作確認をしています。

対応内容が、API, Web, iOS とあった場合、以下の様な一覧になります。

```
- Done
    - iOS UI Design @morita7453
    - Web/Desktop UI Design @morita7453
    - API design @ngs
- Production QA
    - API implementation @qubo
- Staging
    - iOS implementation @ngs
- In development
    - Frontend implementation @yueki
```

## workflow != .Perfect

このように、情報共有にも工夫しながら、日々の開発を回しています。

ただし、我々の製品同様、このワークフローも完成形ではありません。

これからも、よりよい運用方法を生み出すべく、日々試行錯誤を繰り返していきます。

もし、この様に、現場主導でワークフローを改善し、切磋琢磨したいエンジニアの方がいらっしゃいましたら、以下の弊社採用ページを覗いてみてください :pray:

https://one-team.com/ja/recruit/

## 発表資料

<script async class="speakerdeck-embed" data-id="8ae7ad4abde340358cbbd36162155a8d" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>


[Loco Partners 社]: http://loco-partners.com/
[Collaboration Hack Meetup]: http://connpass.com/event/28624/
[Oneteam Inc.]: https://one-team.com/ja/
[Oneteam]: https://one-team.com/ja/
[参画]: /2015/08/01/hello-oneteam/
[末尾]: /2016/04/14/document-driven-development/#発表資料
