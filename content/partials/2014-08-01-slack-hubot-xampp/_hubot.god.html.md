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
