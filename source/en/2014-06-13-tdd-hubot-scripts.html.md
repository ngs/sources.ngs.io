---
title: TDD Hubot scripts with gulp+mocha
description: I configured mocha tests for my Hubot scripts.
date: 2014-06-13 12:20
public: true
tags: hubot, tdd, gulp, mocha, test, npm
alternate: true
ogp:
  og:
    image:
      '': https://avatars0.githubusercontent.com/u/480938?s=460
      type: image/png
      width: 460
      height: 460
---

I created [3 Hubot scripts] and published to [npm][npm], however I worried about that there are no unit tests with them.

So I configured them unit tests with [gulp] and [mocha].

READMORE

package.json
------------

I added the following npm packages to `devDependencies`:

```js
"devDependencies": {
  "hubot": "^2.7.5",
  "gulp": "^3.7.0",
  "coffee-script": "^1.7.1",
  "gulp-coffee": "^2.0.1",
  "gulp-util": "^2.2.16",
  "hubot-mock-adapter": "^1.0.0",
  "gulp-mocha": "^0.4.1",
  "nock": "^0.34.1",
  "chai": "^1.9.1",
  "gulp-clean": "^0.3.0",
  "gulp-coffeelint": "^0.3.3",
  "gulp-watch": "^0.6.5"
}
```


Require modules for testing
---------------------------

I use:

- **[Chai Assertion Library]** to use `expect` matcher.
- **[nock]** to mock HTTP responses.

In the top of `yourscript_spec.coffee`:

```coffee
# Hubot classes
Robot = require("hubot/src/robot")
TextMessage = require("hubot/src/message").TextMessage

# Load assertion methods to this scope
chai = require 'chai'
nock = require 'nock'
{ expect } = chai
```


The mock Hubot adapter
------------------

**[hubot-mock-adapter]** is a simple Hubot adapter that just emits events: `send`, `reply`, `topic`, `play` immediately.

Create [Robot] instance with `mock-adapter`.

```coffee
robot = new Robot null, 'mock-adapter', yes, 'TestHubot'
```


This means:

- Loads adapter from npm modules.
- Uses [hubot-mock-adapter].
- HTTP server is on.
- Responds to messages with `TestHubot ...` prefix.

Load your script
----------------

To load scripts to test, call `Robot:loadFile`.

This method loads listeners and parses command helps written in comment.

Loading adapter should be connected to data source. So call them in `connected` event handler.

```coffee
robot.adapter.on 'connected', ->
  # Project script
  robot.loadFile path.resolve('.', 'src', 'scripts'), 'browserstack.coffee'
  # Path to scripts bundled in hubot npm module
  hubotScripts = path.resolve 'node_modules', 'hubot', 'src', 'scripts'
  robot.loadFile hubotScripts, 'help.coffee'
```


`hubot help` command is implemented in [help.coffee].


Test help commands
------------------

`Robot:loadFile` method loads scripts to parse command helps to list in help asynchronously.

So you need to wait for commands to be actually loaded before exit the scope.

```coffee
do waitForHelp = ->
  if robot.helpCommands().length > 0
    do done
  else
    setTimeout waitForHelp, 100
```


then you can describe help response.

```coffee
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
```


[Hubot v2.7.5] has a bug with help parser that adds prefix twice.

I fixed it and sent a [pull request#712] that was merged. (not yet published to npm.)

Catch exceptions in event handler
---------------------------------

On test failure in event handlers, `chai.AssertionError` might be thrown in event handlers and that kills process by default.

It needs to `try catch` and done with error if caught errors.

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


Mock HTTP
---------

I use [nock] that overrides native [http.ClientRequest] module to responses mock data.

```coffee
nock('http://www.browserstack.com')
  .post('/screenshots')
  .reply 200, job_id: 'abcd1234' # JSON response

```


[nock] also avoids all HTTP requests, call `nock.disableNetConnect()` on `beforeEach`.

```coffee
do nock.disableNetConnect
http.get 'http://google.com/'
# this code throw NetConnectNotAllowedError with message
# Nock: Not allow net connect for "google.com:80"

```


For more details, read [nock documentation].

Clean stuff on afterEach
------------------------

### Close HTTP server

`Error: listen EADDRINUSE` will occur without closing [express] server.

```coffee
robot.server.close()
```


### Clean HTTP mocking

If you test error handling, same error will occur other again without calling `nock.cleanAll()`.

```coffee
nock.cleanAll()
```


gulpfile.coffee
---------------

From version 3.7.0, gulp supports gulpfiles written in CoffeeScript.

gulp watch exits on test failure
--------------------------------

[gulp-watch] exits on test failure by default.

To prevent this, emit `end` event in error handler like the below:

```coffee
gulp.task 'watch', ->
  gulp.src(['src/**/*.coffee', 'spec/*.coffee'])
    .pipe watch(files)->
      files
        .pipe(coffee(bare: yes)
          .pipe(mocha reporter: process.env.MOCHA_REPORTER || 'nyan')
          .on('error', -> @emit 'end'))
```


Make sure `mocha` pipe should pipe to `coffee` pipe.

[3 Hubot scripts]: https://github.com/search?q=user%3Angs+hubot&type=Repositories&ref=searchresults
[Hobot]: https://hubot.github.com
[npm]: http://npmjs.org
[gulp]: http://gulpjs.com/
[mocha]: http://visionmedia.github.io/mocha/
[hubot-mock-adapter]: https://github.com/blalor/hubot-mock-adapter
[Chai Assertion Library]: http://chaijs.com/
[nock]: https://github.com/pgte/nock
[nock documentation]: https://github.com/pgte/nock#readme
[Robot]: https://github.com/github/hubot/blob/master/src/robot.coffee
[http.ClientRequest]: http://nodejs.org/api/http.html#http_class_http_clientrequest
[gulp-watch]: https://github.com/floatdrop/gulp-watch
[gulp-mocha]: https://github.com/sindresorhus/gulp-mocha
[express]: http://expressjs.com/
[Hubot v2.7.5]: https://github.com/github/hubot/commit/04b97eada0018bfc049d88f47b91bce15e54f1bc
[pull request#712]: https://github.com/github/hubot/pull/712
[help.coffee]: https://github.com/github/hubot/blob/master/src/scripts/help.coffee
