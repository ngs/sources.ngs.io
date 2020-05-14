---
title: "Coveralls plugin for fastlane"
description: "Published Coveralls plugin for fastlane"
date: 2018-07-07 23:59
public: true
tags: ruby, fastlane, ci, coveralls, testing, xcode
alternate: true
ogp:
  og:
    image:
      "": 2018-07-07-fastlane-plugin-coveralls/main.png
      type: image/png
      width: 992
      height: 525
---

![](images/2018-07-07-fastlane-plugin-coveralls/main.png)

I've just published a [fastlane]&nbsp;[plugin] that sends Xcode code coverage to [Coveralls] and its depending library [xccoveralls] that also works as standalone command line tool.

- [ngs/fastlane-plugin-coveralls][plugin]
- [ngs/xccoveralls][xccoveralls]

READMORE

## Quick Start

Run the following command

```sh
fastlane add_plugin coveralls
```

Add the following line to your `Fastfile`

```rb
lane :send_coveralls do
  coveralls
end
```

Make sure `Code Coverage` checkbox is turned on for your test target.

![](images/2018-07-07-fastlane-plugin-coveralls/checkbox.png)

Then you can send coverage data from `fastlane` command

```sh
export XCCOVERALLS_REPO_TOKEN=... # grab yours from Coveralls.io
bundle exec fastlane send_coveralls
```

You can check [CI2Go] coverage on [Coveralls](https://coveralls.io/github/ngs/ci2go) and [Fastfile](https://github.com/ngs/ci2go/blob/master/fastlane/Fastfile#L119-L124).

## Motivation

I tried to introduce [Xcov] which is built into [fastlane action][xcov action], but it does not send covered lines because it uses `.xccovreport` or `.xccoverage` file which contains only summary of test coverage.

So I started implementing with `xcrun xccov` which was introduced in Xcode 9.3.

```sh
# List files
$ xcrun xccov view --file-list DerivedData/Logs/Build/*.xccovarchive

# Code coverage for specific file
$ xcrun xccov view --file /Users/ngs/src/CI2Go/AppDelegate.swift \
    DerivedData/Logs/Build/*.xccovarchive
```

ref: [xccov: Xcode Code Coverage Report for Humans](https://medium.com/xcblog/xccov-xcode-code-coverage-report-for-humans-466a4865aa18)

Please send me [issues] if you have any.

Enjoy XCTesting 👨‍💻

[coveralls]: https://coveralls.io/
[fastlane]: https://fastlane.tools/
[plugin]: https://github.com/ngs/fastlane-plugin-coveralls
[xccoveralls]: https://github.com/ngs/xccoveralls
[ci2go]: https://github.com/ngs/ci2go
[xcov]: https://github.com/nakiostudio/xcov
[issues]: https://github.com/ngs/fastlane-plugin-coveralls/issues
[xcov action]: https://docs.fastlane.tools/actions/xcov/
