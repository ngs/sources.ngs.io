robot.adapter.on 'connected', ->
  # Project script
  robot.loadFile path.resolve('.', 'src', 'scripts'), 'browserstack.coffee'
  # Path to scripts bundled in hubot npm module
  hubotScripts = path.resolve 'node_modules', 'hubot', 'src', 'scripts'
  robot.loadFile hubotScripts, 'help.coffee'
