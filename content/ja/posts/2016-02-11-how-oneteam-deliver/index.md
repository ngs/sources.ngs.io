---
title: "Oneteam アプリのビルド + 配信自動化 #meguroes"
description: "Meguro.es で発表させていただいた、Electron アプリのビルド + 配信自動化 について の詳細"
date: 2016-02-11 18:30
public: true
tags: electron, meguro.es, meetup, oneteam, webpack, react.js, circleci, docker
alternate: false
ogp:
  og:
    image:
      "": 2016-02-11-how-oneteam-deliver/oneteam.jpg
      type: image/jpeg
      width: 1200
      height: 630
---

![](oneteam.jpg)

2016-02-10、アルコタワーにあるドリコムさんで開催された [Meguro.es] で、弊社 [Oneteam] が行っている、[Electron] アプリのビルド + 配信自動化について、発表をさせていただきました。

スライドは [この記事の最後](/2016/02/11/how-oneteam-deliver/#embed-slide)に埋め込んでいます。

スライドだけだと活用し辛いと思うので、Web 側のデプロイ方法も含めて、こちらで詳しく掲載します。

READMORE

## 技術スタック

![](techstack.png)

[Oneteam] は、以下の様な技術スタックで開発しています。

- Frontend
  - フレームワーク: [React.js], [Flux]
  - WebSocket SaaS: [Pusher]
  - ビルドツール: [Webpack]
  - Web 版
    - メイン HTML: [nginx] + [Amazon EC2 Container Service]
    - その他資材: Amazon S3 + CloudFront
  - Desktop 版 (Windows/Mac)
    - [Electron]
- Backend
  - Scala ([Spray] + [Akka])
  - [Amazon EC2 Container Service]
  - [Amazon RDS for Aurora]
  - などなど

これらのビルド・デプロイ・配布の一連の作業は、誰でも手間無く着手できる様にするため、[CircleCI] のコンテナ上で自動化しています。

## CI の流れ

### 1. ビルド

ビルドは至ってシンプルです。

#### 1.1. Webpack + Jade (`index.html`) ビルド

```sh
jade src/templates/index.jade --out build
webpack --config config/webpack.config.babel.js
```

#### 1.2. Docker Image ビルド

`index.html` のみをホストする、必要最低限の構成です。

```sh
FROM ubuntu:14.04
MAINTAINER Atsushi Nagase<ngs@oneteam.co.jp>

RUN apt-get update -y && apt-get install -y software-properties-common python-software-properties
RUN apt-add-repository -y ppa:nginx/stable
RUN apt-get update -y && apt-get install -y curl supervisor nginx

RUN mkdir -p /var/www/app/script
RUN mkdir -p /var/www/app/public
RUN echo <%= `cat files/etc/supervisor/supervisord.conf`.inspect %> > /etc/supervisor/supervisord.conf
RUN echo <%= `cat files/etc/supervisor/conf.d/nginx.conf`.inspect %> > /etc/supervisor/conf.d/nginx.conf
RUN echo <%= `cat files/etc/nginx/nginx.conf`.inspect.gsub(/\$/, '\\$') %> > /etc/nginx/nginx.conf
RUN echo <%= `cat ../build/index.html`.inspect %> > /var/www/app/public/index.html
ADD files/public/favicon.ico /var/www/app/public/favicon.ico

CMD ["/usr/bin/supervisord", "-n"]
```

```sh
cd docker && erb Dockerfile.erb > Dockerfile
docker build -t $TARGET .
```

## 2. テスト

- [jest] で単体テスト
- [Serverspec] で Docker Image をテスト

### 3. Web 版デプロイ

#### 3.1. Docker Image Push

Docker Hub に `oneteam/our-ubuntu:comuque-web-production-b1234` の様な、CI ビルド番号を使ったタグ名で Push します。

```sh
docker push "${DOCKER_REPO}:${TAG_WEB}-production-b${CIRCLE_BUILD_NUM}"
```

#### 3.2. S3 バケットに `index.html` 以外の資材をアップロード

```js
/*eslint no-process-env: 0 no-console: 0*/
import s3 from "s3";
import path from "path";
import ProgressBar from "progress";

let client = s3.createClient();
let uploader = client.uploadDir({
  localDir: path.resolve(__dirname, "../build/assets"),
  deleteRemoved: false,
  s3Params: {
    Bucket: process.env.S3_BUCKET,
    ACL: "public-read",
    Prefix: "assets/",
  },
});

let barCache = {};
let bar = (name, current, total) => {
  let b = (barCache[name] =
    barCache[name] ||
    new ProgressBar(`${name} [:bar] :percent (:current/:total)`, {
      total: 1,
      width: 20,
    }));
  b.total = total;
  b.curr = current;
  b.render();
  return b;
};

uploader.on("error", (err) => {
  throw err;
});

uploader.on("progress", () => {
  if (!uploader.doneMd5) {
    bar("md5", uploader.progressMd5Amount, uploader.progressMd5Total);
  } else if (uploader.progressTotal > 0) {
    bar("uploading", uploader.progressAmount, uploader.progressTotal);
  }
});

uploader.on("end", () => {
  console.log("\ndone uploading");
});
```

#### 3.3. ECS タスク更新

このビルドで Push したタグ名を参照する様、タスクを更新します。

`ecs-task-definitions/(production|staging)-service.json.erb` の抜粋

```js
{
  "family": "comuque-frontend-<%= ENV['ENV_NAME'] %>",
  "containerDefinitions": [
    {
      "image": "<%= ENV['DOCKER_REPO'] %>:comuque-web-<%= ENV['ENV_NAME'] %>-b<%= ENV['CIRCLE_BUILD_NUM'] %>",
      "name": "<%= ENV['CONTAINER_NAME'] %>",
      "cpu": 2,
      "memory": 1638,
      "essential": true,
      "portMappings": [{ "hostPort": 80, "containerPort": <%= ENV['CONTAINER_PORT'] %>, "protocol": "tcp" }],
      "environment": [],
      "essential": true
    },
  ], // ...
}
```

ERb をレンダリングして

```sh
erb ecs-task-definitions/${ENV_NAME}-service.json.erb > .ecs-task-definition.json
```

Task Definition を更新し、リビジョン ID を `jq` で取得します。

```sh
TASK_DEFINITION_JSON=$(aws ecs register-task-definition \
  --family $TASK_FAMILY \
  --cli-input-json "file://$(pwd)/.ecs-task-definition.json")
TASK_REVISION=$(echo $TASK_DEFINITION_JSON | jq .taskDefinition.revision)
```

次に Service を更新します。

```sh
aws ecs update-service \
  --cluster ${CLUSTER} \
  --service ${SERVICE_NAME} \
  --task-definition ${TASK_FAMILY}:${TASK_REVISION} \
  --desired-count ${DESIRED_COUNT}
```

### 4. Desktop 版配布

Desktop 版のビルドは、コードサインを行う `codesign` コマンドなど、Xcode に付属するツールが必要なので、CircleCI のデフォルトコンテナの Ubuntu 上では行えません。

そのため、ビルド成果物を、一旦別リポジトリに Push して、iOS アプリなどをビルドするための、[Darwin コンテナ]上でビルドします。

```sh
git add -A build && cd build
git push --force $YET_ANOTHER_GIT_REPO $CIRCLE_BRANCH
```

以下、Darwin コンテナで行っているビルド処理です

#### 4.1. 証明書インポート

証明書の類をバージョン管理するのは、セキュリティ上良くないので、[iOS のビルドで行っていた]のと同様に、CircleCI の環境変数に格納し、Keychain に取り込みます。

```sh
DIR=tmp/certs
KEYCHAIN=$HOME/Library/Keychains/circle.keychain
KEYCHAIN_PASSWORD=`openssl rand -base64 48`
rm -rf $DIR
mkdir -p $DIR
echo $APPLE_AUTHORITY_BASE64 | base64 -D > $DIR/apple.cer
echo $APPLE_ROOT_CA_BASE64 | base64 -D > $DIR/apple-root-ca.cer
echo $DISTRIBUTION_KEY_BASE64 | base64 -D > $DIR/dist.p12
echo $DISTRIBUTION_CERTIFICATE_BASE64 | base64 -D > $DIR/dist.cer
echo $INSTALLER_KEY_BASE64 | base64 -D > $DIR/installer.p12
echo $INSTALLER_CERTIFICATE_BASE64 | base64 -D > $DIR/installer.cer
echo $DEVELOPER_KEY_BASE64 | base64 -D > $DIR/developer.p12
echo $DEVELOPER_CERTIFICATE_BASE64 | base64 -D > $DIR/developer.cer
security create-keychain -p "$KEYCHAIN_PASSWORD" circle.keychain
security import $DIR/apple.cer -k $KEYCHAIN -T /usr/bin/codesign -A
security import $DIR/apple-root-ca.cer -k $KEYCHAIN -T /usr/bin/codesign -A
security import $DIR/dist.cer  -k $KEYCHAIN -T /usr/bin/codesign -A
security import $DIR/dist.p12  -k $KEYCHAIN -T /usr/bin/codesign -P "$KEY_PASSWORD" -A
security import $DIR/installer.cer  -k $KEYCHAIN -T /usr/bin/codesign -A
security import $DIR/installer.p12  -k $KEYCHAIN -T /usr/bin/codesign -P "$KEY_PASSWORD" -A
security import $DIR/developer.cer  -k $KEYCHAIN -T /usr/bin/codesign -A
security import $DIR/developer.p12  -k $KEYCHAIN -T /usr/bin/codesign -P "$KEY_PASSWORD" -A
security list-keychain -s $KEYCHAIN
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN
rm -rf $DIR
```

#### 4.2. Homebrew で必要なソフトウェアのインストール

Electron アプリのビルドには、Homebrew で以下のソフトウェアをインストールする必要があります。

- [XQuartz]
- [Node.js]
- [Wine]
- [MakeNSIS]

```sh
brew install Caskroom/cask/xquartz nodenv wine makensis
nodenv install v4.1.0 && nodenv global v4.1.0
```

ただし、これをまじめに行うと、30 分以上 Dependencies のところで時間を使ってしまいます。

![](ci-screen1.png)

そのため、Homebrew の `/usr/local/Celler` と nodenv ディレクトリを Tarball で固めて、S3 バケットにアップロードし、

```sh
cd /usr/local && cvfz $CIRCLE_ARTIFACTS/HomebrewCellar.tgz Celler
nodenv install v4.1.0 && nodenv global v4.1.0
npm install -g electron-builder electron-packager && nodenv rehash
cd /usr/local && tar cvfz $CIRCLE_ARTIFACTS/nodenv.tgz nodenv
aws s3 cp $CIRCLE_ARTIFACTS/HomebrewCellar.tgz "s3://$S3_BUCKET/HomebrewCellar.tgz" --acl public-read
aws s3 cp $CIRCLE_ARTIFACTS/nodenv.tgz "s3://$S3_BUCKET/nodenv.tgz" --acl public-read
```

以降、それをダウンロードして使うことで、1 分以内で依存解決できる様になりました。

```sh
cd /usr/local && \
curl -o HomebrewCellar.tgz https://$S3_BUCKET.s3.amazonaws.com/HomebrewCellar.tgz && \
tar xvfz HomebrewCellar.tgz
brew link --force $(brew list | sed -e 's/ruby20//g')
export S='if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi'
echo $S >> ~/.bash_profile
cd /usr/local && curl -o nodenv.tgz https://$S3_BUCKET.s3.amazonaws.com/nodenv.tgz && \
tar xvfz nodenv.tgz && node -v && npm -v
```

#### 4.3. アプリケーションバンドルの作成

[electron-packager] という npm モジュールを使い、アプリケーションバンドルを作成します。

```sh
BUNDLE_ID_PREFIX=io.one-team
VERSION=$(node -e 'process.stdout.write(require("./app/package.json").version)')
# Mac
electron-packager ./app Oneteam \
  --out build \
  --platform=darwin --arch=x64 \
  --version=$ELECTRON_VERSION \
  --build-version=$BUILD_NUM \
  --app-bundle-id=$BUNDLE_ID_PREFIX.Oneteam \
  --app-version=$VERSION \
  --asar \
  --helper-bundle-id=$BUNDLE_ID_PREFIX.OneteamHelper \
  --icon=assets/osx/app.icns \
  --overwrite \
  --sign 'Developer ID Application: Oneteam Inc. (579B4336F6)'
# Windows
electron-packager ./app Oneteam \
  --out build \
  --platform=win32 --arch=ia32 \
  --version=$ELECTRON_VERSION \
  --asar \
  --icon=assets/win/app.ico \
  --overwrite \
  --version-string=$VERSION
```

#### 4.4. インストーラーの作成

[electron-builder] という npm モジュールを使い、Mac 用の Disk Image と Windows 用の Installer 実行ファイルを作成します。

マウントしたディスクの背景画像や、インストーラーのカスタマイズなどが簡単に行えるので、おすすめです。

```sh
electron-builder build/Oneteam-darwin-x64/Oneteam.app \
  --platform=osx --out=$DIR --config=packager.json

electron-builder build/Oneteam-win32-ia32 \
  --platform=win --out=$DIR --config=packager.json
```

packager.json

```json
{
  "osx": {
    "title": "Oneteam",
    "background": "assets/osx/installer.png",
    "icon": "assets/osx/mount.icns",
    "icon-size": 128,
    "contents": [
      { "x": 488, "y": 264, "type": "link", "path": "/Applications" },
      { "x": 212, "y": 264, "type": "file" }
    ]
  },
  "win": {
    "title": "Oneteam",
    "icon": "assets/win/app.ico"
  }
}
```

![](mounted.png)

#### 4.5. Chat Room に通知

最後に、成果物を Amazon S3 にアップロードし、その URL を Chat Room に通知します。

```sh
aws s3 sync dist \
  "s3://$S3BUCKET/desktop/${VERSION}/b${BUILD_NUM}" \
  --acl public-read

curl -X POST --data-urlencode "payload={ ... }" \
  $SLACK_WEBHOOK_URL
```

現在、弊社のプロダクトは Bot 連携に対応していないため、Slack を使っていますが、現在 Bot 用のエンドポイントとライブラリを開発しているので、近々、自社製品で完結するようになります。

## TODOs

上記の様に、いろいろ頑張って自動化していますが、まだ未対応のものがあります。

### Windows 用の証明書のインストール

[SignTool] を使って、Windows インストーラーにコードサインを行わないと、ダウンロード時に、不明な開発者のソフトウェアだと認識され、ユーザーに警告が行われます。

今は、以下のコマンドを手作業で行い、配布元のホストにアップロードしています。

```
C:\"Program Files (x86)"\"Windows Kits"\10\bin\x86\signtool.exe `
  sign /f oneteam-installer.pfx `
  /p naisho `
  /d "Oneteam Installer" `
  /t http://timestamp.comodoca.com/authenticode `
  "Oneteam Setup.exe"
```

### Auto Updater の設定

[Nuts] というバージョンフィード配信のアプリケーションの雛形を元に、Electron の [Auto Updater] の仕組みを使った Heroku 上で動作する様、セットアップしたのですが、Electron アプリ側で、フィードデータの受信後、クラッシュしてしまう問題にぶつかり、塩漬けになっています。

```sh
#!/bin/bash

set -eu

VERSION=$(node -e "process.stdout.write(require('./app/package.json').version)")
BUILD_NUM=$(node -e "process.stdout.write(require('./app/package.json').buildNumber)")

heroku config:set \
  LATEST_VERSION=$VERSION \
  LATEST_ZIP_URL=https://$S3_BUCKET/desktop/$VERSION/b$BUILD_NUM/osx/Oneteam.zip \
  --app $NUTS_HEROKU_APP
```

また、Mac AppStore での配信も検討しているので、その際には、iTunes Connect への配信作業も自動化しようと思っています。

## 発表資料

<div id="embed-slide"><script async class="speakerdeck-embed" data-id="309ef195b4804ddf9805bb9aee845d6a" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script></div>

## We&apos;re HIRING!

最後に、宣伝で申し訳ないですが、こんな風に、開発フローやソフトウェアの UX にこだわりを持って一緒に開発していただける、エンジニアを絶賛採用中なので、もし興味がある方がいらっしゃいましたら、以下の採用ページをご覧いただき、連絡いただけるととてもうれしいです 🙏

https://one-team.com/ja/recruit/

[meguro.es]: http://meguroes.connpass.com/event/25018/
[oneteam]: https://one-team.com/ja/products/
[react.js]: https://facebook.github.io/react/
[flux]: https://facebook.github.io/flux/
[pusher]: https://pusher.com/
[nginx]: http://nginx.org/
[amazon ec2 container service]: https://aws.amazon.com/jp/ecs/
[amazon rds for aurora]: https://aws.amazon.com/jp/rds/aurora/
[spray]: http://spray.io/
[akka]: http://akka.io/
[electron]: http://electron.atom.io/
[webpack]: https://webpack.github.io/
[circleci]: https://circleci.com/
[jest]: https://facebook.github.io/jest/
[serverspec]: http://serverspec.org/
[darwin コンテナ]: https://circleci.com/docs/ios
[ios のビルドで行っていた]: https://ja.ngs.io/2015/03/24/circleci-ios/#鍵と証明書の読み込み
[xquartz]: http://www.xquartz.org/
[node.js]: https://nodejs.org/
[wine]: https://www.winehq.org/
[makensis]: http://nsis.sourceforge.net/Docs/Chapter3.html
[electron-packager]: https://github.com/maxogden/electron-packager
[electron-builder]: https://github.com/loopline-systems/electron-builder
[signtool]: https://msdn.microsoft.com/en-us/library/windows/desktop/aa387764(v=vs.85).aspx
[auto updater]: http://electron.atom.io/docs/latest/api/auto-updater/
[nuts]: https://github.com/GitbookIO/nuts
