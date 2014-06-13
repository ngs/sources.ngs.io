```coffee
waitForHelp = ->
  if robot.helpCommands().length > 0
    do done
  else
    setTimeout waitForHelp, 100
do waitForHelp
```
