---
title: GitHub API v3 でリポジトリを作成して、ファイルをコミットする
description: Qiita Hackathon の向けて GitHub API v3 の予習をしてみました。
date: 2012-12-18 00:00
public: true
tags: json, github, api, curl, hackathon
---

[Qiita Hackathon](http://qiitahackathon03.peatix.com) の向けて GitHub API v3 の予習をしてみました。

READMORE

## 1. Application を作成する

https://github.com/settings/applications/new

作成した Application の ID, Secret は環境変数にしておくと便利です。

```bash
$ CLIENT_ID=0123456789abcdef0123
$ CLIENT_SECRET=0123456789abcdef0123456789abcdef01234567
```

## 2. Access token を取得する

以下の URL へアクセスすると、App Authorization の画面がでてくるので、Allow ボタンをクリックする。<br>
https://github.com/login/oauth/authorize?client_id=$CLIENT_ID&scope=repo


http://www.example.com/auth/callback?code=0123456789abc など、1 の画面で指定した Callback URL にリダイレクトされる。

GET パラメータについている code を使って以下の cURL コマンドを実行

```bash
$ curl -X POST \
    -d "code=$CODE" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    https://github.com/login/oauth/access_token
```

以下の様なレスポンスが返ってきます。

```bash
access_token=0123456789abcdef0123456789abcdef01234567&token_type=bearer
```

これも環境変数にしておきましょう。

```bash
$ TOKEN=0123456789abcdef0123456789abcdef01234567
$ AUTH_HDR="Authorization: bearer $TOKEN"

```


## 3. リポジトリを作成する

```bash
$ curl -H "$AUTH_HDR" -X POST \
    -d '{"name":"testrepos0001","auto_init":true}' \
    https://api.github.com/user/repos
```

自分のアカウントに testrepos0001 というリポジトリが作成されます。

```bash
$ REPO="api.github.com/repos/ngs/testrepos0001"
```

## 4. BLOB を作成する
```bash
$ CONTENT=`cat README.mkdn`
$ curl -H "$AUTH_HDR" -X POST \
    -d "{\"content\":\"$CONTENT\",\"encoding\":\"utf-8\"}" \
    https://$REPO/git/blobs
```

以下の様なレスポンスが返ってきます。

```json
{
  "url": "https://api.github.com/repos/ngs/testrepos0001/git/blobs/03c6fa49370fb5ff5c5b57f134c4f0b3f9b8fc44",
  "sha": "03c6fa49370fb5ff5c5b57f134c4f0b3f9b8fc44"
}
```

sha の値を使います。

```bash
$ BLOB1_SHA=03c6fa49370fb5ff5c5b57f134c4f0b3f9b8fc44
```

バイナリをコミットするときは、base64 にします。

```bash
$ CONTENT=`curl https://help.github.com/assets/set-up-git.gif | base64`
$ curl -H "$AUTH_HDR" -X POST \
    -d "{\"content\":\"$CONTENT\",\"encoding\":\"base64\"}" \
    https://$REPO/git/blobs

```

以下の様なレスポンスが返ってきます。

```json
{
  "url": "https://api.github.com/repos/ngs/testrepos0001/git/blobs/def187dee0bb8478f502f2c6942a19dbaca24118",
  "sha": "def187dee0bb8478f502f2c6942a19dbaca24118"
}
```

sha の値を使います。

```bash
$ BLOB2_SHA=def187dee0bb8478f502f2c6942a19dbaca24118
```


## 5. Tree を作成する

```bash
$ curl -H "$AUTH_HDR" -X POST \
    -d "{\"tree\":[
      {\"path\":\"README.mkdn\",\"mode\":\"100644\",\"type\":\"blob\",\"sha\":\"$BLOB1_SHA\"},
      {\"path\":\"test.png\",\"mode\":\"100644\",\"type\":\"blob\",\"sha\":\"$BLOB2_SHA\"}
    ]}" \
    https://$REPO/git/trees
```

以下の様なレスポンスが返ってきます。

```json
{
   "tree" : [
      {
         "sha" : "03c6fa49370fb5ff5c5b57f134c4f0b3f9b8fc44",
         "mode" : "100644",
         "url" : "https://api.github.com/repos/ngs/testrepos0001/git/blobs/03c6fa49370fb5ff5c5b57f134c4f0b3f9b8fc44",
         "path" : "README.mkdn",
         "type" : "blob",
         "size" : 10
      },
      {
         "sha" : "def187dee0bb8478f502f2c6942a19dbaca24118",
         "mode" : "100644",
         "url" : "https://api.github.com/repos/ngs/testrepos0001/git/blobs/def187dee0bb8478f502f2c6942a19dbaca24118",
         "path" : "test.png",
         "type" : "blob",
         "size" : 3413
      }
   ],
   "sha" : "0583674d7b9fbe9a77d6d06b4b6ef14143a56dd5",
   "url" : "https://api.github.com/repos/ngs/testrepos0001/git/trees/0583674d7b9fbe9a77d6d06b4b6ef14143a56dd5"
}
```

sha の値を使います。

```bash
$ TREE_SHA=0583674d7b9fbe9a77d6d06b4b6ef14143a56dd5
```

## 6. 現在の Commit の SHA を取得する

```bash
$ PARENT_SHA=`curl -H "$AUTH_HDR" https://$REPO/branches/master | ruby -r'json' -e 'puts JSON.parse(STDIN.read)["commit"]["sha"]'`
```

## 7. Commit を作成する

```bash
$ curl -H "$AUTH_HDR" -X POST \
    -d "{\"message\":\"test commit 1\", \"tree\":\"$TREE_SHA\", \"parents\":[\"$PARENT_SHA\"] }" \
    https://$REPO/git/commits
```

以下の様なレスポンスが返ってきます。

```json
{
   "committer" : {
      "email" : "atsn.ngs@gmail.com",
      "date" : "2012-12-18T04:05:48Z",
      "name" : "Atsushi NAGASE"
   },
   "tree" : {
      "sha" : "0583674d7b9fbe9a77d6d06b4b6ef14143a56dd5",
      "url" : "https://api.github.com/repos/ngs/testrepos0001/git/trees/0583674d7b9fbe9a77d6d06b4b6ef14143a56dd5"
   },
   "sha" : "4131dae7cd29ec8c701cff96a74ec339fe303428",
   "url" : "https://api.github.com/repos/ngs/testrepos0001/git/commits/4131dae7cd29ec8c701cff96a74ec339fe303428",
   "author" : {
      "email" : "atsn.ngs@gmail.com",
      "date" : "2012-12-18T04:05:48Z",
      "name" : "Atsushi NAGASE"
   },
   "parents" : [
      {
         "sha" : "4082a83e86fe908153963a1d4fe46ee5f94361c5",
         "url" : "https://api.github.com/repos/ngs/testrepos0001/git/commits/4082a83e86fe908153963a1d4fe46ee5f94361c5"
      }
   ],
   "message" : "test commit 1"
}
```

sha の値を使います。

```bash
$ COMMIT_SHA=4131dae7cd29ec8c701cff96a74ec339fe303428
```

## 7. master リファレンスを更新する

```bash
$ curl -H "$AUTH_HDR" -X PATCH \
    -d "{\"force\":false, \"sha\":\"$COMMIT_SHA\"}" \
    https://$REPO/git/refs/heads/master
```

以下の様なレスポンスが返ってきます。

```json
{
  "url": "https://api.github.com/repos/ngs/testrepos0001/git/refs/heads/master",
  "ref": "refs/heads/master",
  "object": {
    "type": "commit",
    "url": "https://api.github.com/repos/ngs/testrepos0001/git/commits/4131dae7cd29ec8c701cff96a74ec339fe303428",
    "sha": "4131dae7cd29ec8c701cff96a74ec339fe303428"
  }
}
```

## 8. 再帰的に Tree の構造を確認してみる

```bash
$ curl -H "$AUTH_HDR" https://$REPO/git/trees/$TREE_SHA?recursive=1
```

以下の様なレスポンスが返ってきます。

```json
{
   "tree" : [
      {
         "sha" : "03c6fa49370fb5ff5c5b57f134c4f0b3f9b8fc44",
         "mode" : "100644",
         "url" : "https://api.github.com/repos/ngs/testrepos0001/git/blobs/03c6fa49370fb5ff5c5b57f134c4f0b3f9b8fc44",
         "path" : "README.mkdn",
         "type" : "blob",
         "size" : 10
      },
      {
         "sha" : "def187dee0bb8478f502f2c6942a19dbaca24118",
         "mode" : "100644",
         "url" : "https://api.github.com/repos/ngs/testrepos0001/git/blobs/def187dee0bb8478f502f2c6942a19dbaca24118",
         "path" : "test.png",
         "type" : "blob",
         "size" : 3413
      }
   ],
   "sha" : "0583674d7b9fbe9a77d6d06b4b6ef14143a56dd5",
   "url" : "https://api.github.com/repos/ngs/testrepos0001/git/trees/0583674d7b9fbe9a77d6d06b4b6ef14143a56dd5"
}
```
