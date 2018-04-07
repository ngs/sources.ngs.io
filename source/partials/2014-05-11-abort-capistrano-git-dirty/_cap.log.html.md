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
