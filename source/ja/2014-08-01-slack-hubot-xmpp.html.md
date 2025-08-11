---
title: Slack を XMPP プロトコルで Hubot と連携する
description: Rapsberry PI の中で Hubot を起動するために、Slack アダプターを使わず XMPP プロトコルで設定しました。
date: 2014-08-01 06:30
public: true
tags: hubot, slack, xmpp
alternate: false
ogp:
  og:
    image:
      '': https://avatars0.githubusercontent.com/u/480938?s=460
      type: image/png
      width: 460
      height: 460
---

個人でも[リモコンとして活用している][hubot-irkit] [Hubot] ですが、いつもの [Heroku] ではなく、[Raspberry PI] の中で起動しようとして、アダプター設定で苦労したので、メモします。

READMORE

## 要件

- ポートフォワーディングを設定していない (したくない)。
- 複数の bot が、同じ Room に常駐し、bot 同士で支持の出し合いを行う必要がある。

## 不採用

### [hubot-gtalk]

今まで [hubot-irkit] は [Google Talk] を Mac OS X の Messages.app に登録して使っていました。

ただ、Google Talk のチャットに複数の bot を常駐させるには、その分アカウント作成が必要になり、スケーラビリティが低いため、不採用にしました。

### [hubot-slack]

仕事でも愛用している [Slack] がオフィシャルで提供している [hubot-slack] アダプタの場合、Webhook を使いメッセージの送受信をしているため、ポートフォワーディングが必要なので、不採用でした。

## 採用

### [Slack] + [hubot-xmpp]

[Slack] は、[XMPP] で会話をするゲートウェイを用意しており、それと [hubot-xmpp] アダプタを連携して、[Hubot] を動かすことにしました。

## 設定方法

前提として、Owner 権限が必要です。

![](2014-08-01-slack-hubot-xmpp/1.png)

[Admin Settings] の Gateways セクションを展開し、上記の様に、XMPP を有効にします。

![](2014-08-01-slack-hubot-xmpp/2.png)

次に、個人の [Gateway 情報画面] を開き、`Host`, `User`, `Pass` 情報を取得し、Raspberry PI 側で、以下の様に環境変数を書き出します。

```bash
export HUBOT_XMPP_HOST=conference.myteam.xmpp.slack.com
export HUBOT_XMPP_ROOMS=general@$HUBOT_XMPP_HOST
export HUBOT_XMPP_USERNAME=hubot@$HUBOT_XMPP_HOST
export HUBOT_XMPP_PASSWORD=<super secret>
```


`HUBOT_XMPP_HOST`: [Gateway 情報画面] にある、`Host` の先頭に、`conference.` を付与したもの。

`HUBOT_XMPP_ROOMS`: `#{ルーム名}@$HUBOT_XMPP_HOST` の形式で、カンマ区切りの文字列。

`HUBOT_XMPP_USERNAME`: ユーザー名。`#{User}@$HUBOT_XMPP_HOST` の形式。

`HUBOT_XMPP_PASSWORD`: [Gateway 情報画面] にある、`Pass`。

## Hubot の起動

あとは、通常と同じく、[hubot-xmpp] を採用した bot を起動するだけです。

もし、新規から始める場合は Hubot プロジェクトを作成し、

```bash
npm install -g hubot
npm install -g hubot-xmpp
npm install -g coffee-script
nodenv rehash
hubot -a xmpp -c pi-hubot
cd pi-hubot
```


起動します。

```bash
hubot -a xmpp
```


しばらくすると ping に応答する様になります。

![](2014-08-01-slack-hubot-xmpp/3.png)

## god の設定

死活管理と自動起動に [god] を使います。

```bash
gem install god
sudo vim /etc/init.d/god # 下記参照
sudo chmod +x /etc/init.d/god
sudo update-rc.d -f god defaults
```


### /etc/god/hubot.god

```rb
# vim: set ft=ruby

God.watch do |w|
  w.name = "hubot"
  w.start = "/home/pi/.nodenv/shims/hubot -a xmpp"
  w.dir = "/home/pi/hubot"
  w.log = "/home/pi/hubot/hubot.log"
  w.env = ENV.select{|k,v| k.start_with? 'HUBOT' }
  w.uid = 'pi'
  w.gid = 'gpio'
  w.keepalive
end
```


### /etc/init.d/god

```bash
#!/bin/bash
#
# god       Startup script for God monitoring tool.
#
# chkconfig: - 85 15
# description: god monitors your system
#

USER=pi
HOME=/home/pi
CONF_DIR=/etc/god/*
PID=/var/run/god.pid
LOG=/var/log/god.log
PATH=/home/pi/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RETVAL=0

source /home/pi/dotfiles/env.d/secret/env.sh

case "$1" in
    start)
      god -P $PID --no-syslog # -l $LOG --log-level warn
      god load $CONF_DIR
      RETVAL=$?
  ;;
    stop)
      kill `cat $PID`
      RETVAL=$?
  ;;
    restart)
      kill `cat $PID`
      god -P $PID --no-syslog # -l $LOG --log-level warn
      god load $CONF_DIR
      RETVAL=$?
  ;;
    status)
      RETVAL=$?
  ;;
    *)
      echo "Usage: god {start|stop|restart|status}"
      exit 1
  ;;
esac

exit $RETVAL
```


引用元: https://gist.github.com/cwsaylor/17522

[hubot-irkit]: https://ja.ngs.io/2014/06/09/hubot-irkit/
[Hubot]: https://hubot.github.com/
[Heroku]: https://www.heroku.com/
[Raspberry PI]: http://www.raspberrypi.org/
[hubot-slack]: https://github.com/tinyspeck/hubot-slack
[hubot-gtalk]: https://github.com/atmos/hubot-gtalk/
[hubot-xmpp]: https://github.com/markstory/hubot-xmpp
[Google Talk]: http://www.google.com/hangouts/
[Slack]: https://slack.com/
[XMPP]: http://ja.wikipedia.org/wiki/Extensible_Messaging_and_Presence_Protocol
[Admin Settings]: https://my.slack.com/admin/settings#change_gateways
[Gateway 情報画面]: https://my.slack.com/account/gateways
[god]: http://godrb.com/
