---
title: "Exporting and importing iTerm 2 Color Schemes"
description: "Exporting and importing iTerm 2 Color Schemes"
date: 2014-05-05T14:00:00+09:00
public: true
tags: ["iterm2", "shell"]
alternate: true
---

I started to manage stuffs with [dotfiles] git repository instead of [Boxen].

I managed iTerm 2 color schemes with [puppet-iterm2] modules", "that was very useful.

<!--more-->

To migrate to [dotfiles]", "I wrote the following scripts to export/import iTerm 2 color schemes.

### Exporting:

This exports color schemes configured in your iTerm 2.

{{< partial "2014-05-05-iterm2-color-schemes/import.sh.html.md" >}}

### Importing:

{{< partial "2014-05-05-iterm2-color-schemes/export.sh.html.md" >}}

[Boxen]: http://boxen.github.com/
[dotfiles]: https://github.com/ngs/dotfiles/
[puppet-iterm2]: https://github.com/ngs/puppet-iterm2
