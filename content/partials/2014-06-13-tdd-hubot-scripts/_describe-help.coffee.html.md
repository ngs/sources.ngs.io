describe 'help', ->
  it 'should have 3', (done)->
    expect(robot.helpCommands()).to.have.length 3
    do done
  it 'should parse help', (done)->
    adapter.on 'send', (envelope, strings)->
      try
        expect(strings[0]).to.equal """
        TestTestHubot help - Displays all of the help commands that TestHubot knows about.
        TestTestHubot help <query> - Displays all help commands that match <query>.
        TestTestHubot screenshot me <url> - Takes screenshot with Browser Stack.
        """
        do done
      catch e
        done e
    adapter.receive new TextMessage user, 'TestHubot help'
