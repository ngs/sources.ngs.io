---
title: RDoc で Twitter Bootstrap を使う
description: Twitter Bootstrap に互換性のある RDoc テンプレートを Hanna Nouveau という Generator を Fork して書きました。
date: 2013-01-20 00:00
public: true
tags: ruby, rdoc, bootstrap
---

Twitter Bootstrap に互換性のある RDoc テンプレートを [Hanna Nouveau](https://github.com/rdoc/hanna-nouveau) という Generator を Fork して書きました。

[http://ngs.github.io/hanna-bootstrap/](http://ngs.github.io/hanna-bootstrap/)

READMORE

## インストール

RubyGems から

```bash
gem install hanna-bootstrap
```

または git-clone

```bash
git clone git://github.com/ngs/hanna-bootstrap.git
```

## 使い方

RDoc::Task の `generator` オプションに `bootstrap` を指定する

```ruby:Rakefile
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.generator = 'bootstrap'
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "RDBI #{version} Documentation"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/   *.rb')
end
```

または、コマンドラインオプションで指定します

```sh:sample.sh
$ rdoc -o doc -f bootstrap lib  .rb
```

