---
title: Hubot で Travis CI の Webhook を受ける
description: 個人で利用している Slack アカウントのサービス連携数を節約するために、Travis CI の Webhook を自分で書きました。
date: 2014-08-24 11:40
public: true
tags: travis-ci, hubot, webhook, slack
alternate: false
ogp:
  og:
    image:
      '': 2014-08-24-travisci-hubot/screen1.png
      type: image/png
      width: 992
      height: 525
---

![](2014-08-24-travisci-hubot/screen1.png)

個人で利用している [Slack] アカウントはフリープランで利用しており、サービス連携数に上限があるので、連携数を節約するために、[Travis CI] の Webhook を [Hubot] Script を使って自分で実装しました。

READMORE

Hubot script
------------

```coffee
# Description:
#   Notifies Travis CI builds
# Configuration:
#   HUBOT_TRAVISCI_ROOM

module.exports = (robot) ->
  robot.router.post "/travisci/hooks", (req, res) ->
    envelope = room: process.env.HUBOT_TRAVISCI_ROOM
    { payload } = req.body
    { status_message, build_url, message, number, repository } = JSON.parse payload
    robot.send envelope, """
    Build##{ number } for #{ repository.owner_name }/#{ repository.name } #{ if status_message is 'Pending' then 'started.' else "finished. (#{status_message})" }
    > #{message}
    #{build_url}
    """
    res.end "OK"
```


.travis.yml
-----------

```yaml
notifications:
  on_success: always
  on_failure: always
  on_start: always
  webhooks: 'http://myhubot.herokuapp.com/travisci/hooks'
```


参照: http://docs.travis-ci.com/user/notifications/#Webhook-notification

[Travis CI]: https://travis-ci.org
[Slack]: https://slack.com/
[Hubot]: https://hubot.github.com/
