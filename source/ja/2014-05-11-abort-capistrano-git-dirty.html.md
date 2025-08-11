---
title: リモートに変更がある場合、Capistrano 2 を使ったデプロイを中断する
description: Capistrano 2 をリモートに変更がある場合、デプロイを中断する様に設定しました。
date: 2014-05-11 19:00
public: true
tags: capistrano, git, deployment
alternate: true
---

Capistrano 2 でデプロイを行う際、コミットされていない変更がリモートにあった場合、デグレードを引き起こすので、それを防ぐために、タスクを中断する様に設定しました。

\# もちろん、リモートの資材をいじるのは良くないことですが、**たまに**やらなきゃいけないときがあるので保険としての作ったものです。

READMORE

```ruby
before "deploy:update_code", 'git:dirty'

namespace :git do
  desc "Check current directory and raise if git status is dirty"
  task :dirty do
    run "cd #{current_path}; git status --porcelain" do|channel, stream, data|
      ignore = [ # Files to omit changes
        'D log/.gitkeep',
        'M db/schema.rb'
      ]
      diff = data.split("\n").reject{|m|
        ignore.include? m.strip
      }
      if diff.size > 0
        abort "Aborting: #{current_path} is dirty:\n #{ diff.join("\n") }"
      end
    end
  end
end
```


もし、リモートに変更があった場合は、以下の様な実行結果になります:

```
$ bundle exec cap deploy
    triggering start callbacks for `deploy'
  * executing `multistage:ensure'
*** Defaulting to `development'
  * executing `development'
  * executing `deploy'
  * executing `deploy:update'
 ** transaction: start
  * executing `deploy:update_code'
    triggering before callbacks for `deploy:update_code'
  * executing `git:dirty'
  * executing "cd /var/www/myservice/current; git status --porcelain"
    servers: ["dev.myservice.com"]
    [ec2-user@dev.myservice.com] executing command
  * executing "cd /var/www/myservice/current; git diff app/controllers/foo_controller.rb"
    servers: ["dev.myservice.com"]
    [ec2-user@dev.myservice.com] executing command
 ** [out :: ec2-user@dev.myservice.com] diff --git a/app/controllers/foo_controller.rb b/app/controllers/editor_controller.rb
 ** [out :: ec2-user@dev.myservice.com] index 08ccd69..aa8da97 100644
 ** [out :: ec2-user@dev.myservice.com] --- a/app/controllers/foo_controller.rb
 ** [out :: ec2-user@dev.myservice.com] +++ b/app/controllers/foo_controller.rb
 ** [out :: ec2-user@dev.myservice.com] @@ -16,8 +16,8 @@ class FooController < ApplicationController
 ** [out :: ec2-user@dev.myservice.com] ##
 ** [out :: ec2-user@dev.myservice.com] ## Do stuff about bar.
 ** [out :: ec2-user@dev.myservice.com] def bar
 ** [out :: ec2-user@dev.myservice.com] -    p_url = request.original_url
 ** [out :: ec2-user@dev.myservice.com] -    p p_url
 ** [out :: ec2-user@dev.myservice.com] +    logger.info request.original_fullpath
 ** [out :: ec2-user@dev.myservice.com] +    p_url = request.original_fullpath.sub %r{^/}, ''
 ** [out :: ec2-user@dev.myservice.com] options = {
 ** [out :: ec2-user@dev.myservice.com] add_js: true,
 ** [out :: ec2-user@dev.myservice.com] mode: "editor",
    command finished in 1465ms
Aborting: /var/www/myservice/current is dirty:
  M app/controllers/foo_controller.rb
```


## Capistano 3

Capistrano 3 は releases ディレクトリに `git clone` を行わないので、このタスクはそのまま移植できません。

現在、別のアプローチで、リモートの変更を自動デプロイから守る方法を模索中です。
