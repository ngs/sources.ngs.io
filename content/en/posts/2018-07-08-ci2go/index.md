---
title: "CI2Go Today widget support"
description: "Released CI2Go 2.1.0 including Today widget support"
date: 2018-07-08 09:00
public: true
tags: ci2go, circleci, ios
alternate: true
ogp:
  og:
    image:
      '': 2018-07-08-ci2go/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](main.jpg)

I've just released version 2.1.0 of [CI2Go], the [CircleCI] client for iPhone and iPad.

[![](/images/appstore.svg.svg)][AppStore]

v2.1.0 contains the following:

- Today widget
- SSH connect
- Delete local artifacts
- Open application by URL

READMORE

## Today widget

![](widget.jpg)

You can add CI2Go widget to [Today] view. This shows recent 5 builds of selected project/branch or your following projects.

## SSH connect

![](ssh.png)

`SSH` section will be shown while running SSH enabled builds if you installed SSH client which supports `ssh://` URI scheme such as Panic's [Prompt].

Launches SSH client when row of container was selected.

## Delete local artifacts

![](artifacts.png)

You can delete downloaded build artifacts from trash can icon which appears by swiping table rows left.

## Open application by URL

CI2Go now handles URI schemes: `chttps://`, `ci2go://`, `ci2go+https://`.

You can open CI2Go by replacing or prefixing protocol part of CircleCI build URL like:

[https://circleci.com/gh/circleci/frontend/3439] to [ci2go://circleci.com/gh/circleci/frontend/3439]

Send me [issues] if you have any.

[CI2Go]: https://itunes.apple.com/app/id940028427?mt=8
[AppStore]: https://itunes.apple.com/app/id940028427?mt=8
[CircleCI]: https://circleci.com
[issues]: https://github.com/ngs/ci2go/issues/new
[https://circleci.com/gh/circleci/frontend/3439]: https://circleci.com/gh/circleci/frontend/3439
[ci2go://circleci.com/gh/circleci/frontend/3439]: ci2go://circleci.com/gh/circleci/frontend/3439
[Prompt]: https://panic.com/prompt/
[Today]: https://support.apple.com/en-us/ht207122
