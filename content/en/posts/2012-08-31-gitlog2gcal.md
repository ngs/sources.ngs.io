---
title: ""Create Events on Google Calendar with Git Commit""
date: 2012-08-31T12:00:00+09:00
public: true
tags: ["google calendar", "git", "python", "google"]
ogp:
  og:
    image:
      '': 2012-08-31-gitlog2gcal/gcal.png
      type: image/png
      width: 1280
      heihgt: 620

---

![Create Events on Google Calendar with Git Commit](2012-08-31-gitlog2gcal/gcal.png)

To track colleagues&apos; work or let colleagues track my work", "we started using Google Calendar with writing Git Commits as events.

<!--more-->

## Requirements

* google-api-python-client
* oauth2
* rfc3339

## Set up

```bash
pip install google-api-python-client oauth2 rfc3339

cd /path/to/project
curl -L http://s.liap.us/gcal-post-commit.py > .git/hooks/post-commit
chmod +x .git/hooks/post-commit

vim .git/hooks/post-commit
```

Create new client on [the console](https://code.google.com/apis/console) and replace variables.

<script src="https://gist.github.com/ngs/3550670.js?file=post-commit.py"></script>
