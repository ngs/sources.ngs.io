---
title: "Middleman Blog を Travis-CI で GitHub Pages に継続デプロイ"
description: "Middleman で作った Blog を Travis-CI で継続デプロイします。"
date: 2013-12-09T01:00:00+09:00
public: true
tags: ["middleman", "travis", "ci"]
---

Octopress Blog では既に設定していた Travis-CI での自動デプロイですが、こちらのブログにも設定します。

`middleman build && middleman deploy` とか毎回コマンドうつの面倒ですもんね。

参考サイト: [Middleman で作った web サイトを Travis + GitHub pages でお手軽に運用する](http://tricknotes.hateblo.jp/entry/2013/06/17/020229)

上記サイトとの違いは、[middleman-deploy](https://github.com/tvaughan/middleman-deploy) プラグインを使っているため、自分で git コマンドを記述する手間が省けます。

<!--more-->


### 1. travis にリポジトリを登録する。

未登録の場合、3 で、
`repository not known to https://api.travis-ci.org/: ngsio/ja.ngs.io` などと怒られた。
[https://travis-ci.org/profile](https://travis-ci.org/profile)、もしくは [https://travis-ci.org/profile/$YOUR_ORGANIZATION$](https://travis-ci.org/profile/$YOUR_ORGANIZATION$) でスイッチを ON にする。

### 2. GitHub の Token を取得する。

[設定画面](https://github.com/settings/applications) から *Personal Access Tokens* セクションの右肩にある *Create new token* ボタンより作成。

### 3. travis より、暗号化されたキーを取得する

```bash
$ travis encrypt -r ngsio/ja.ngs.io "GH_TOKEN=(2 で取得した GitHub Token)"
```

### 4. .travis.yml を書く


```yaml
---
language: ruby
script: bundle exec middleman build
env:
  global:
    - GIT_COMMITTER_NAME='ngs@travis-ci'
    - GIT_COMMITTER_EMAIL='a+travis@ngs.io'
    - GIT_AUTHOR_NAME='ngs@travis-ci'
    - GIT_AUTHOR_EMAIL='a+travis@ngs.io'
    - secure: "(3 で取得した secure の値)"
after_success:
  - '[ "$TRAVIS_BRANCH" == "master" ] && [ $GH_TOKEN ] && bundle exec middleman deploy >/dev/null 2>&1'
```

### 5. config.rb にデプロイ設定を追記する

```ruby
activate :deploy do |deploy|
  deploy.method = :git
  deploy.branch = 'gh-pages'
  deploy.remote = "https://#{ENV['GH_TOKEN']}@github.com/ngsio/ja.ngs.io.git"
end
```
