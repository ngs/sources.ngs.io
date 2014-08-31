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
