---
title: "CircleCI で S3 に iOS アプリの AdHoc ビルドとダウンロードページを作成し、Slack で通知する"
description: "先日、CircleCI に CI サービスを変更した 続きで、TODO に残っていた、ビルド番号の同期と Amazon S3 への配信の自動化を設定しました。"
date: 2015-04-05 11:30
public: true
tags: circleci, ios, ci, xcode, apple, aws, ci2go, slack
alternate: false
ogp:
  og:
    image:
      "": 2015-04-05-circleci-ios/dlpage.png
      type: image/png
      width: 750
      height: 670
---

![](2015-04-05-circleci-ios/dlpage.png)

先日、[CircleCI に CI サービスを変更した][prev] 続きで、TODO に残っていた、ビルド番号の同期と [Amazon S3] への配信の自動化を設定しました。

**[ngs/ci2go on GitHub](https://github.com/ngs/ci2go)**

READMORE

## ビルド番号の同期

以下のスクリプトで `$CIRCLE_BUILD_NUM` とアプリケーションのビルド番号を使って `CFBundleVersion` を更新します。

`#{Short Version Number}.#{CIRCLE_BUILD_NUM}` のフォーマット、例えば `1.1.0.123` の様なバージョン番号になります。

```bash
#!/bin/bash
set -eu

v=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${APPNAME}/Info.plist"`

for f in `ls **/Info.plist`; do
  echo $f
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${v}.${CIRCLE_BUILD_NUM}" "$f"
done
```

## [Amazon S3] への配信

[Amazon S3] へは、AdHoc 用のバイナリ、plist ファイル、ダウンロードページを配信します。

`.ipa` バイナリは、[前回、既に設定してある](/2015/03/24/circleci-ios/#adhoc-ビルド) AdHoc 用のものを使用します。

[DeployGate で設定したのと同じく](/2015/03/24/circleci-ios/#deploygate-へデプロイ)、[shenzhen] を使い、`.ipa` ファイルのアップロードを行い、
ダウンロードページの生成とアップロードを行う `rake` タスクを実行します。

サンプル: https://littleapps-ios-build.s3.amazonaws.com/ngs/ci2go/52/index.html

```bash
#!/bin/sh
set -eu

DIST_PATH="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${CIRCLE_BUILD_NUM}"

bundle exec ipa distribute:s3 \
  --file Distribution/AdHoc/${APPNAME}.ipa \
  --dsym Distribution/AdHoc/${APPNAME}.app.dSYM.zip \
  --access-key-id=$AWS_ACCESS_KEY_ID \
  --secret-access-key=$AWS_SECRET_ACCESS_KEY \
  --path=$DIST_PATH \
  --bucket=$S3_BUCKET \
  --acl=public-read \
  --region=$AWS_REGION \
  --create

bundle exec rake adhoc:upload
```

`rake` タスクで、アップロードが完了したら、ダウンロードページの URL を [Slack] で通知されます。

![](2015-04-05-circleci-ios/slack.png)

### 環境変数

| Name                    | Description                    |
| ----------------------- | ------------------------------ |
| `SLACK_CHANNEL`         | 通知先の Slack チャンネル      |
| `SLACK_WEBHOOK_URL`     | Slack の Webhook URL           |
| `S3_BUCKET`             | 配布先の S3 バケット           |
| `AWS_ACCESS_KEY_ID`     | AWS のアクセスキー ID          |
| `AWS_SECRET_ACCESS_KEY` | AWS のシークレットアクセスキー |
| `AWS_REGION`            | S3 のリージョン                |

### Rakefile

```rb
require 'erb'
require 'aws-sdk'
require 'shenzhen'

def upload_path
  "#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{ENV['CIRCLE_BUILD_NUM']}"
end

def s3_upload(src)
  s3 = AWS::S3.new
  bucket = s3.buckets[ENV['S3_BUCKET']]
  obj = nil
  File.open(src) do |fd|
    obj = bucket.objects.create "#{upload_path}/#{File.basename(src)}", fd, acl: 'public-read'
  end
  obj.public_url.to_s
end

class AdHocPage
  attr_accessor :name
  def initialize(name)
    @name = name
  end
  def render
    ERB.new(IO.read("Resources/adhoc-templates/#{name}.erb")).result(binding)
  end
  def plist_print(key)
    Shenzhen::PlistBuddy.print "#{APP_NAME}/Info.plist", key
  end
  def filesize
    File.open("#{ADHOC_DIR}/#{APP_NAME}.ipa").size
  end
  def ipa_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{upload_path}/#{APP_NAME}.ipa"
  end
  def build_url
    "https://circleci.com/gh/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{build_num}"
  end
  def build_num
    ENV['CIRCLE_BUILD_NUM']
  end
  def plist_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{upload_path}/app.plist"
  end
  def icon_url
    ENV['ICON_URL']
  end
  def bundle_identifier
    plist_print :CFBundleIdentifier
  end
  def bundle_version
    plist_print :CFBundleVersion
  end
  def title
    APP_NAME
  end
  def upload
    s3_upload "#{ADHOC_DIR}/#{name}"
  end
end

namespace :adhoc do
  desc 'Generate AdHoc Distribution Page'
  task :page do
    %w{index.html app.plist}.each do|file|
      IO.write "#{ADHOC_DIR}/#{file}", AdHocPage.new(file).render
    end
  end
  task :upload => [:page] do
    AdHocPage.new('app.plist').upload
    page = AdHocPage.new('index.html')
    page_url = page.upload
    %x{./Scripts/slack-notify.sh "<#{page_url}|*Build #{page.bundle_version}*> is available 📱"}
  end
end
```

### slack-notify.sh

依存ライブラリを減らすために cURL で [Slack] の Webhook を叩くことにしました。

```
#!/bin/bash
set -eu

PAYLOAD=`ruby -rjson -e "print ({ channel: ENV['SLACK_CHANNEL'], username: ENV['APPNAME'], text: ARGV[0], icon_url: ENV['ICON_URL'] }).to_json" "$1"`
echo $PAYLOAD

curl -X POST --silent --data-urlencode "payload=${PAYLOAD}" $SLACK_WEBHOOK_URL
```

### .plist ファイルのテンプレート

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>items</key>
  <array>
    <dict>
      <key>assets</key>
      <array>
        <dict>
          <key>kind</key>
          <string>software-package</string>
          <key>url</key>
          <string><%= ipa_url %></string>
        </dict>
      </array>
      <key>metadata</key>
      <dict>
        <key>bundle-identifier</key>
        <string><%= bundle_identifier %></string>
        <key>bundle-version</key>
        <string><%= bundle_version %></string>
        <key>kind</key>
        <string>software</string>
        <key>title</key>
        <string><%= title %></string>
      </dict>
    </dict>
  </array>
</dict>
</plist>
```

### ダウンロードページのテンプレート

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta name="viewport" content="width=device-width" />
    <meta charset="utf-8" />
    <title><%= title %> <%= bundle_version %> AdHoc Install</title>
    <link
      rel="stylesheet"
      type="text/css"
      href="https://maxcdn.bootstrapcdn.com/bootswatch/3.3.4/flatly/bootstrap.min.css"
    />
  </head>
  <body>
    <div class="container">
      <div class="text-center">
        <h1><%= title %> <small><%= bundle_version %></small></h1>
        <p>
          <img
            src="<%= icon_url %>"
            width="170"
            height="170"
            class="img-rounded"
          />
        </p>
        <p>
          <a
            href="itms-services://?action=download-manifest&amp;url=<%= plist_url %>"
            class="btn btn-primary btn-lg"
            ><i class="glyphicon glyphicon-cloud-download"></i>&nbsp;Download</a
          >
        </p>
        <p>
          <small
            ><%= sprintf '%.02f', (filesize.to_f / 1024 / 1024) %> MB</small
          >
          /
          <a href="https://github.com/ngs/ci2go/issues/new">Feedbacks</a>
          /
          <a href="<%= build_url %>">Build#<%= build_num %></a>
        </p>
      </div>
    </div>
  </body>
</html>
```

[amazon s3]: http://aws.amazon.com/jp/s3/
[prev]: /2015/03/24/circleci-ios/
[shenzhen]: https://github.com/nomad/shenzhen
[slack]: https://slack.com/
