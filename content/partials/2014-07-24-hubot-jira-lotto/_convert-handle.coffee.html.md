# scripts/convert-handle.coffee
module.exports = (robot)->
  map =
    ngs: 'atsushi_nagase'
  robot.convertHandle = (name)->
    map[name] || name
