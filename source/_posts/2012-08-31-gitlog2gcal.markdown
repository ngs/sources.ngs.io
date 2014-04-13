---
layout: post
title: "Create Events on Google Calendar with Git Commit"
date: 2012-08-31 12:00
comments: true
categories: [Google Calendar, Git, Python, Google]
---

{% img /images/posts/2012-08-31-gitlog2gcal.png 640 310 'Create Events on Google Calendar with Git Commit' %}

To track colleagues&apos; work or let colleagues track my work, we started using Google Calendar with writing Git Commits as events.

<!--more-->

## Requirements

* google-api-python-client
* oauth2
* rfc3339

## Set up

    pip install google-api-python-client oauth2 rfc3339
    
    cd /path/to/project
    curl -L http://s.liap.us/gcal-post-commit.py > .git/hooks/post-commit
    chmod +x .git/hooks/post-commit
    
    vim .git/hooks/post-commit

Create new client on [the console](https://code.google.com/apis/console) and replace variables.

{% gist 3550670 post-commit.py %}