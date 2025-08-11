---
title: Abort Capistrano 2 deployment if remote is dirty
description: I configured Capistrano 2 to abort deployment if remote directory is dirty.
date: 2014-05-11 19:00
public: true
tags: capistrano, git, deployment
alternate: true
---

I configured Capistrano 2 to abort deployment if remote directory is dirty.

Because uncommited changes in remote directory will cause degrade.

\# Of course, modifying source code in remote directory is bad, but sometimes we need to do it.

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


If there are some changes in remote, deploy log would be like this:

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

Capistrano 3 doesn't clone repository for each releases so we can't port this task.

I'm seeking other solution to protect remote changes from automated deployments.
