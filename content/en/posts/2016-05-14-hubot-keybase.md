---
title: "PGP encrypted messages for Keybase users in our chat rooms"
description: "I've released hubot-keybase, a Hubot script to encrypt messages for Keybase users."
date: 2016-05-14 07:45
public: true
tags: hubot, keybase, pgp, encryption
alternate: true
ogp:
  og:
    image:
      '': 2016-05-14-hubot-keybase/screen.png
      type: image/png
      width: 1358
      height: 737
---

![](2016-05-14-hubot-keybase/screen.png)

I've released **[hubot-keybase]**, a [Hubot] script to encrypt messages for [Keybase] users.

ref: **[ngs/hubot-keybase][hubot-keybase] on GitHub**

READMORE

## How to use

When you type message in your chat room like:

```sh
hubot keybase encrypt:ngs Hi there!
#                     ^ Keybase username!
```

Hubot replies PGP encrypted message using public key for specified user.

```
-----BEGIN PGP MESSAGE-----
Version: OpenPGP.js v2.3.0
Comment: http://openpgpjs.org

wcBMA2GjYRB9O5DgA...(snip)
-----END PGP MESSAGE-----
```

## Install

1\. Add `hubot-keybase` to dependencies.

```bash
npm install --save hubot-keybase
```

2\. Update `external-scripts.json`

```json
["hubot-keybase"]
```

## Feedbacks

If you find some bugs or request, feel free to drop me an issue on GitHub repository or PRs are welcome :)

https://github.com/ngs/hubot-keybase/issues

Enjoy encrypting!

[Keybase]: https://keybase.io/
[hubot-keybase]: https://github.com/ngs/hubot-keybase
[Hubot]: https://hubot.github.com/
