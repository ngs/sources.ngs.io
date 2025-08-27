---
title: "Slack と Qiita:Team を使って気楽に日報 #qiita_hackathon"
description: "2014/12/13、リクルート本社で行われた Qiita API v2 Hackathon で、hubot-qiita を開発し、Chat 日報 なるワークフローを発表しました。"
date: 2014-12-14 21:15
public: true
tags: hubot, qiita, hackathon
alternate: false
ogp:
  og:
    image:
      '': 2014-12-14-hubot-qiita/screen.png
      type: image/png
      width: 1760
      height: 2130
---

![](https://raw.githubusercontent.com/ngs/hubot-qiita/master/img/screen.gif)

[Hubot Advent Calendar 2014] 14日目の記事です。

2014/12/13、リクルート本社で行われた [Qiita API v2 Hackathon] で、**Chat 日報** なるワークフローを発表しました。

ありがたいことに、優秀賞をいただき、[Kindle Voyage] がいただける様です。

READMORE

## Hackathon のテーマ

今回の Hackathon のテーマは、**Qiita APIv2を利用して毎日の開発が楽しくなるツールの開発** とのことでした。

**開発は、ほっておいても楽しい** ので、開発に当てる時間をより多く取れる様に、日報の作成を楽にする、という目的で開発しました。

## 作ったもの

Qiita API v2 が発表されてすぐ、[Hubot] スクリプト [hubot-qiita] 開発に着手したのですが、業務内では別業務、業務外では [CI2Go] を作成していたので、未完成のまま塩漬けになっていました。

今回、前半は、これをリリースまで作りきり、その後、本題の機能追加を行いました。

[Qiita:Team] に登録されているテンプレートの、タイトル、タグ、本文から、`%{}` で囲われた変数名を取り出し、その内容を Hubot が質問する、というものです。

## 実際のやりとり

```md
me > hubot qiita list templates
hubot > Listing templates:
        1. 日報
        2. Daily standup minutes
        3. Sales meeting minutes
me > hubot qiita new item with template 1
hubot > ngs: 本日の作業内容?
me > - Qiita Hackathon に参加した。
     - [hubot-qiita](https://github.com/ngs/hubot-qiita) なるものを開発した。
hubot > ngs: 発生した問題?
me > - 作業完了までご飯を我慢してたら、空腹で倒れるかと思った。
hubot > ngs: 明日の作業予定?
me > - 子守をします。
hubot > ngs: 所感?
me > **hubot-qiita, Code snippet も貼れて便利。**

     ```swift
     public func resetViews() {
      let windows = UIApplication.sharedApplication().windows as [UIWindow]
      for window in windows {
        let subviews = window.subviews as [UIView]
        for v in subviews {
          v.removeFromSuperview()
          window.addSubview(v)
        }
      }
     }
     ```
hubot > ngs: 見出し?
me > Chat 日報ができる様になった
```

上記の様に、Hubot と対話することで、Qiita に以下の様な投稿が作成されます。

![](screen.png)

## テンプレート

この例での、テンプレートは以下です。

タイトル: `%{hubot:user} 日報 %{Year}/%{month}/%{day} %{見出し}`

本文:

```md
# 本日の作業内容

%{本日の作業内容}

# 発生した問題

%{発生した問題}

# 明日の作業予定

%{明日の作業予定}

# 所感

%{所感}

---

%{hubot:room} より投稿
```

`hubot:user`, `hubot:room` は、対話が行われたユーザー名、チャットルーム名が勝手に埋まります。


作成途中、キャンセルしたくなった場合には、`cancel!` と発言してください。

インストール方法、その他、詳しい使い方は [README] を参照してください。

## エイリアス

毎回、テンプレート ID を探して、長いコマンドを打つのは面倒だと思うので、同僚の [@dtaniwaki] が公開している、[hubot-alias] を使うと便利です。

参照: [hubot-scriptのエイリアス on Qiita](http://qiita.com/dtaniwaki/items/0ca82c09cbafb7645f32)

```
me > hubot alias 日報=qiita new item with template 43
```

これで、`hubot 日報` と発言するだけで、日報の作成を開始できます。

## QiitaButton

今回の Hackathon で発表され、同じく、優秀賞を獲得された、[QiitaButton] をブログのソースにも追加しました。

[ngs/sources.ngs.io]

が、`docs` 配下しかサポートしてないので、使えませんでした。

よかったら対象ディレクトリと拡張子 (このブログは `.md.erb` を使っています) を設定できる様にしていただけると嬉しいです。

[Qiita API v2 Hackathon]: http://peatix.com/event/55420
[README]: https://github.com/ngs/hubot-qiita#readme
[hubot-qiita]: https://github.com/ngs/hubot-qiita
[Hubot Advent Calendar 2014]: http://www.adventar.org/calendars/384
[Qiita:Team]: https://teams.qiita.com
[@dtaniwaki]: http://dtaniwaki.com
[hubot-alias]: https://github.com/dtaniwaki/hubot-alias
[Kindle Voyage]: http://www.amazon.co.jp/gp/product/B00M0EVYCC/ref=as_li_ss_tl?ie=UTF8&camp=247&creative=7399&creativeASIN=B00M0EVYCC&linkCode=as2&tag=atsushnagased-22
[Hubot]: https://hubot.github.com
[QiitaButton]: http://qiita.com/fmy/items/57088e1d1bd412557123
[CI2Go]: https://ja.ngs.io/2014/11/26/ci2go/
[ngs/sources.ngs.io]: https://github.com/ngs/sources.ngs.io#readme
