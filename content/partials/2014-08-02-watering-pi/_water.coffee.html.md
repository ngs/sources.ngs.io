# Descriotion:
#   Water plants
#
# Commands:
#   hubot water (for n seconds)- Water plants. Defaults to 10 seconds.
#
gpio = require 'pi-gpio'
PIN = 11
DEFAULT_SECONDS = 10
module.exports = (robot)->
  busy = no
  robot.respond /\s*water(?:\s+for\s+(\d+)\s*s(?:ec(?:onds?)?)?)?\s*$/i, (msg)->
    if busy
      msg.reply "Sorry, I'm busy :("
      return
    sec = if msg.match[1] then parseInt(msg.match[1]) else DEFAULT_SECONDS
    msg.reply "Watering for #{sec} sec. :droplet:"
    gpio.open PIN, 'output', (err)->
      busy = yes
      gpio.write PIN, 1, ->
        setTimeout ->
          gpio.write PIN, 0, ->
            gpio.close PIN
            msg.reply "Done watering :seedling:"
            busy = no
        , sec * 1000
