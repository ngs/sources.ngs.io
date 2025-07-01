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
