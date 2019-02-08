---
title: Go Release Binary GitHub Action
description: GitHub Marketplace に Go Release Binary Action を公開しました。
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

![](2019-02-08-go-release-action/main.png)

GitHub Marketplace に Go Release Binary Action を公開しました。

[Go Release Binary Action on GitHub Marketplace](https://github.com/marketplace/actions/go-release-binary)

この GitHub Action は Go 言語で実装されたコマンドラインツールのバイナリを GitHub のリリースが作成されたら、自動的にビルドを行い、リリース資材に tarball を追加します。

READMORE

## 利用例

![](2019-02-08-go-release-action/release.png)

[ngs/aws1pif@v1.0.0](https://github.com/ngs/aws1pif/releases/tag/v1.0.0)

以下のように .workflow ファイルを設置し、GitHub の Releases 機能を使って新しく Release を作成すると、対象のコミットのビルド成果物を自動的にビルドし、リリース資材として追加します。

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
