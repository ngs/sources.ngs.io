---
title: Go Release Binary GitHub Action
description: Published Go Release Binary Action on GitHub Marketplace
date: 2019-02-08 21:00
public: true
tags: github, actions, golang
alternate: true
ogp:
  og:
    image:
      '': 2019-02-08-go-release-action/main.png
      type: image/png
      width: 992
      height: 525
---

![](main.png)

I’ve published Go Release Binary Action on GitHub Marketplace.

[Go Release Binary Action on GitHub Marketplace](https://github.com/marketplace/actions/go-release-binary)

This GitHub Action builds and uploads Go build artifacts as Release Artifacts automatically when Release was created on GitHub repository.

READMORE

## GitHub Actions

GitHub Actions is provided as Limited Public Beta now (8th, Feb, 2019). You can start using this feature by signing up from the below page.

https://github.com/features/actions

## How to Use

![](release.png)

[ngs/aws1pif@v1.0.0](https://github.com/ngs/aws1pif/releases/tag/v1.0.0)

Place .workflow file like the below. The workflow builds and uploads build artifacts from referencing commit when new Release was created using GitHub Releases feature.

```hcl
# .github/main.workflow

workflow "Build" {
  on = "release"
  resolves = [
    "release darwin/amd64",
    "release windows/amd64",
    "release linux/amd64",
  ]
}

action "release darwin/amd64" {
  uses = "ngs/go-release.action@v1.0.0"
  env = {
    GOOS = "darwin"
    GOARCH = "amd64"
  }
  secrets = ["GITHUB_TOKEN"]
}

action "release windows/amd64" {
  uses = "ngs/go-release.action@v1.0.0"
  env = {
    GOOS = "windows"
    GOARCH = "amd64"
  }
  secrets = ["GITHUB_TOKEN"]
}

action "release linux/amd64" {
  uses = "ngs/go-release.action@v1.0.0"
  env = {
    GOOS = "linux"
    GOARCH = "amd64"
  }
  secrets = ["GITHUB_TOKEN"]
}
```
