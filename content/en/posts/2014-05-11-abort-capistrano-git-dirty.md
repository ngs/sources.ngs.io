---
title: "Abort Capistrano 2 deployment if remote is dirty"
description: "I configured Capistrano 2 to abort deployment if remote directory is dirty."
date: 2014-05-11T19:00:00+09:00
public: true
tags: ["capistrano", "git", "deployment"]
alternate: true
---

I configured Capistrano 2 to abort deployment if remote directory is dirty.

Because uncommited changes in remote directory will cause degrade.

\# Of course", "modifying source code in remote directory is bad", "but sometimes we need to do it.

<!--more-->

{{< partial "2014-05-11-abort-capistrano-git-dirty/git-dirty.rb.html.md" >}}

If there are some changes in remote", "deploy log would be like this:

{{< partial "2014-05-11-abort-capistrano-git-dirty/cap.log.html.md" >}}

## Capistano 3

Capistrano 3 doesn't clone repository for each releases so we can't port this task.

I'm seeking other solution to protect remote changes from automated deployments.
