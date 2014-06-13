```coffee
it 'should handle json parse error', (done)->$
  adapter.on 'send', (envelope, strings)->
    try
      expect(strings[0]).to.equal 'Wont be sent'
      do done
    catch e
      done e
  adapter.receive new TextMessage user, 'TestHubot help'
```
