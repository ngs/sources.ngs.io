---
title: Google Calendar に登録している当番表を使って Slack Room のトピックを更新する
description: Google Calendar に登録している当番表を使って Slack Room のトピックを更新する Hubot Script を作りました。
date: 2014-09-01 06:00
public: true
tags: hubot, developer productivity, slack, automation, kaizenplatform
alternate: false
ogp:
  og:
    image:
      '': 2014-09-01-hubot-touban-topic/1.png
      type: image/png
      width: 1029
      height: 322
---

![](2014-09-01-hubot-touban-topic/1.png)

Google Calendar に登録している当番表を使って Slack Room のトピックを更新する [Hubot] Script を作りました。

自分が働いている [KAIZEN platform Inc.] のエンジニアチームでは、現時点で、日々のカスタマーサポート業務から発生する技術的な質問・調査に日替わりで対応する、**LiveOps マスター**、火・木の週二回、(ほぼ自動化されているものの) デプロイの進行を行う、**Deploy マスター** という、2つの当番があります。

READMORE

開発したきっかけ
-------------

今まで、毎朝 10:00 から行われる、デイリースクラムなどで、アナログに誰が当番だったか確認していましたが、休暇などで、イレギュラーな進行が発生すると、前回、誰まで担当が回ったか、交代してもらった場合、次は誰に回せばいいかなど、混乱する問題が発生しました。

それに対応するため、それぞれの当番のカレンダーを作成しました。

![](2014-09-01-hubot-touban-topic/2.png)

緑がデプロイ、オレンジが LiveOps です。デプロイが2日にまたがっているのは、本番デプロイ前日に QA 環境にデプロイするためです。

Slack 対応
----------

それぞれの当番には、専用の [Slack] ルームがあるので、それぞれのルームのトピックを更新する Hubot Script を作りました。

以下のコマンドで、呼び出したルームに応じて、トピックを更新します。

```
hubot update topic
```

毎朝 6:00 に自動的に Topic 更新を行うため、[hubot-cron] を使いました。Hubot は、自分自身のメッセージには応答しないため、別に Cron 用の Hubot を立ちあげています。

```
cronbot 0 21 * * 0-4 say hubot update topic
```

日〜木の 21:00 になっているのは Heroku の Timezone が UTC に設定されているためです。

Slack API
---------

現時点では Webhook から `/topic` コマンドを叩いても、更新ができないため、[Slack API] の [channels.setTopic] メソッドを使う必要があります。

[Slack API] は [OAuth 2] を利用しており、ユーザーに対して発行される [Access Token] を使うため、発行したユーザーが Topic を更新している様に見えます。(冒頭のスクリーンショットを参照してください)

今後、同じ様に、[Slack API] を利用したユースケースが増えれば Bot 用にアカウントを取ることを検討すると思いますが、現時点では、Topic 更新にしか使われていないため、現時点では長瀬個人の Access Token を使用して、スクリーンショットの様に、毎朝 @ngs がトピックを更新している様に見えます。

実装コード
--------

長いですが、npm で公開するほど未だ汎用化できていないので、そのまま貼り付けます。

```coffee
# Description:
#   Updates topic for (LiveOps|Deploy) master
#
# Commands:
#   hubot update topic - Update topic for the room
#
# Configuration:
#   HUBOT_SLACK_OAUTH_TOKEN
#   HUBOT_DEPLOYMENT_MASTER_ICS_URL
#   HUBOT_LIVEOPS_MASTER_ICS_URL
#   HUBOT_DEPLOYMENT_MASTER_ROOM
#   HUBOT_LIVEOPS_MASTER_ROOM

QS   = require 'querystring'
ical = require 'ical'

module.exports = (robot) ->
  {
    HUBOT_SLACK_OAUTH_TOKEN
    HUBOT_DEPLOYMENT_MASTER_ICS_URL
    HUBOT_LIVEOPS_MASTER_ICS_URL
    HUBOT_DEPLOYMENT_MASTER_ROOM
    HUBOT_LIVEOPS_MASTER_ROOM
  } = process.env
  missings = []
  'HUBOT_SLACK_OAUTH_TOKEN HUBOT_DEPLOYMENT_MASTER_ICS_URL HUBOT_LIVEOPS_MASTER_ICS_URL HUBOT_DEPLOYMENT_MASTER_ROOM HUBOT_LIVEOPS_MASTER_ROOM'.split(/\s+/g).forEach (key)->
    missings.push key unless process.env[key]?
  if missings.length > 0
    robot.logger.error "Required configuration#{ if missings.length == 1 then ' is' else 's are' } missing: #{ missings.join ', ' }"

  Rooms =
    deployment:
      ics: HUBOT_DEPLOYMENT_MASTER_ICS_URL
      id: HUBOT_DEPLOYMENT_MASTER_ROOM
    'live-ops':
      ics: HUBOT_LIVEOPS_MASTER_ICS_URL
      id: HUBOT_LIVEOPS_MASTER_ROOM

  getCalendar = (key, callback)->
    return no unless config = Rooms[key]
    ical.fromURL config.ics, {}, callback
    yes

  getCurrentEvent = (key, callback)->
    exports.getCalendar key, (err, data)->
      now = new Date()
      try
        for uid, event of data
          { start, end, summary } = event
          continue unless start? && end? && summary?
          event.start = start = new Date start unless start instanceof Date
          event.end = end = new Date end unless end instanceof Date
          if start <= now && end > now
            callback.apply @, [event]
            break
      catch e
        robot.logger.error e

  updateTopic = (key, callback = ->)->
    robot.logger.info "Updating topic for #{key}"
    exports.getCurrentEvent key, (event)->
      topic = null
      try
        robot.logger.info "Current event is #{ JSON.stringify event, undefined, 2 }"
        { end, summary } = event
        date = new Date end.getTime() - 1
        date = "#{date.getMonth() + 1}/#{date.getDate()}"
        switch key
          when 'deployment'
            topic = "#{date} のデプロイマスターは @#{summary} です"
          when 'live-ops'
            topic = "#{date} の Live Ops マスターは @#{summary} です"
          else
            callback.apply @, null
            return
        exports.requestUpdateTopic Rooms[key].id, topic, callback
      catch e
        robot.logger.error e

  requestUpdateTopic = (channel, topic, callback)->
    robot.logger.info "Updating #{channel} with topic #{topic}"
    token = HUBOT_SLACK_OAUTH_TOKEN
    params = { token , channel, topic }
    qstr = QS.stringify params
    robot
      .http('https://slack.com/api/channels.setTopic')
      .header('Content-Type', 'application/x-www-form-urlencoded')
      .post(qstr) callback

  robot.respond /\s*update\s+topic\s*/i, (msg)->
    { room } = msg.envelope
    exports.updateTopic room

  exports = { getCalendar, updateTopic, getCurrentEvent, requestUpdateTopic }
```


[Hubot]: https://hubot.github.com/
[KAIZEN platform Inc.]: http://kaizenplatform.in/
[Slack]: https://slack.com/
[hubot-cron]: https://github.com/miyagawa/hubot-cron
[channels.setTopic]: https://api.slack.com/methods/channels.setTopic
[Slack API]: https://api.slack.com/
[Access Token]: https://api.slack.com/#auth
[OAuth 2]: https://api.slack.com/docs/oauth
