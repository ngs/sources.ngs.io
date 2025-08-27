---
title: "Rails アプリの Docker Image ビルドと Amazon EC2 Container Service へのデプロイの自動化"
description: "現在構築中のサービスの Rails アプリケーションのインフラとして、Amazon EC2 Container Service (ECS) を採用し、自動化を頑張ってみた内容を公開します。"
date: 2015-09-14 07:45
public: true
tags: aws, ecs, rails, docker, infrastructure, circleci, serverspec
alternate: false
ogp:
  og:
    image:
      '': 2015-09-14-ecs-docker-rails/build-docker-image.png
      type: image/png
      width: 992
      height: 525
---

現在構築中のサービスの Rails アプリケーションのインフラとして、[Amazon EC2 Container Service] \(ECS) を採用し、自動化を頑張ってみた内容を公開します。

サンプルコード、Docker Image はそれぞれ、以下で公開しています。

- [ngs/docker-rails-example on GitHub](https://github.com/ngs/docker-rails-example)
- [atsnngs/docker-rails-example on Quay.io](https://quay.io/repository/atsnngs/docker-rails-example)
- [ngs/docker-rails-example on CircleCI](https://circleci.com/gh/ngs/docker-rails-example)

READMORE

## 構成

今回開発しているアプリケーションは、以下の様な構成です。

- Rails 4.2
- MySQL (Amazon RDS)
- Redis (ElastiCache)
- [nginx] + [unicorn] socket
- ActiveJob + [Sidekiq]

## CI フロー

[circle.yml] に以下の様な処理フローを設定しています。

- `dependencies/override`
  - awscli, jq インストール
  - 依存 Gem Library, Docker Image インストール
  - MySQL, Redis コンテナ起動
  - Docker Image ビルド
  - Serverspec の依存ライブラリインストール
- `test/override`
  - Rails アプリケーション側の Rspec
  - Docker Image の Serverspec
- `test/post`
  - CI ビルド毎の Docker Image をレジストリーに Push
    - `${DOCKER_REPO}:web-b${CIRCLE_BUILD_NUM}`
    - `${DOCKER_REPO}:job-b${CIRCLE_BUILD_NUM}`
- `master` ブランチ: ビルド番号なしの Docker Image をレジストリーに Push
  - `${DOCKER_REPO}:web`
  - `${DOCKER_REPO}:job`
- `deployment/$ENV_NAME` ブランチ
  - ビルド番号付きの Docker Image をソースに、Task Definition を作成
  - `db:migrate` 用のタスクを作成
  - Service を更新する
  - 既存タスクを終了させる (無停止デプロイは未設定)

## Roles

以下の 2つの Role を持つコンテナを起動します。

- `job`
  - [Sidekiq] のデーモンを常駐させる
  - Cron で Rake Task を実行する
- `web`
  - [nginx]
  - [unicorn]

常駐プロセスは [Supervisor] で監視します。

## 環境変数

CircleCI 上で、以下の環境変数を _Project Settings > Environment variables_ にて設定しています。

| Name                       | Description |
| -------------------------- | ----------- |
|  `AWS_DEFAULT_REGION`      |  AWS Commandline 用。今回は `us-east-1` を使いました。 |
|  `DATABASE_URL_PRODUCTION` |  Production 環境用の `DATABASE_URL`.<br>例: `mysql2://root:password@docker-rails-example.xxxxx.us-east-1.rds.amazonaws.com:3306/docker_rails_example_production` |
| `DOCKER_EMAIL`            | レジストリーの Email。Robot user の場合 `.` で OK |
| `DOCKER_PASS`             | レジストリーの Password |
| `DOCKER_REPO_HOST`        | レジストリーの Host: `quay.io` |
| `DOCKER_REPO`             | リポジトリ名: `quay.io/atsnngs/docker-rails-example` |
| `DOCKER_USER`             | レジストリーの Username |
| `REDIS_URL_PRODUCTION`     | Production 環境用の `REDIS_URL`.<br>例: `redis://docker-rails-example.xxxx.0001.use1.cache.amazonaws.com/sidekiq_production` |

AWS の Credential は _Project Settings > AWS permissions_ にて設定しています。

## Dockerfile

2つの Role によって、分岐が発生するので、Erb テンプレートで条件分岐と環境変数の出力を行います。

### Dockerfile.erb

```bash
FROM ubuntu:14.04
MAINTAINER Atsushi Nagase<a@ngs.io>

RUN apt-get update -y && apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:nginx/stable
RUN apt-add-repository -y ppa:brightbox/ruby-ng
RUN apt-get update -y && apt-get install -y \
    locales \
    language-pack-en \
    language-pack-en-base \
    openssh-server \
    curl \
    supervisor \
    build-essential \
    git-core \
    g++ \
    libcurl4-openssl-dev \
    libffi-dev \
    libmysqlclient-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    python-software-properties \
    zlib1g-dev \
    ruby2.2-dev \
    ruby2.2

ENV \
  BUNDLE_PATH=/var/www/shared/vendor/bundle \
  RAILS_ENV=production \
  RAILS_ROOT=/var/www/app

RUN gem install bundler --no-rdoc --no-ri
RUN mkdir -p $RAILS_ROOT
WORKDIR ${RAILS_ROOT}

RUN (echo <%= `cat Gemfile`.inspect %> > "${RAILS_ROOT}/Gemfile") && (echo <%= `cat Gemfile.lock`.inspect %> > "${RAILS_ROOT}/Gemfile.lock")
RUN mkdir -p $BUNDLE_PATH && \
  mkdir -p vendor && \
  rm -rf vendor/bundle && \
  ln -s $BUNDLE_PATH vendor/bundle && \
  (bundle check || bundle install --without test development darwin assets --jobs 4 --retry 3 --deployment)

## Locales
RUN [ -f /var/lib/locales/supported.d/local ] || touch /var/lib/locales/supported.d/local
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN dpkg-reconfigure --frontend noninteractive locales

RUN echo <%= `cat docker/files/etc/supervisor/supervisord.conf`.inspect %> > /etc/supervisor/supervisord.conf

<% if ENV['ROLE'] == 'web' %>
RUN apt-get update -y && apt-get install -y nginx
<% end %>

COPY . $RAILS_ROOT
WORKDIR ${RAILS_ROOT}

RUN mkdir -p $BUNDLE_PATH && \
  mkdir -p vendor && \
  rm -rf vendor/bundle && \
  ln -s $BUNDLE_PATH vendor/bundle && \
  (bundle check || bundle install --without test development darwin assets --jobs 4 --retry 3 --deployment) && \
  (echo "SECRET_KEY_BASE=$(./bin/rake secret)" > .env)

ENV ROLE=<%= ENV['ROLE'] %>

<% if ENV['ROLE'] == 'web' %>
EXPOSE 80
ADD docker/files/etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD docker/files/etc/supervisor/conf.d/unicorn.conf /etc/supervisor/conf.d/unicorn.conf
ADD docker/files/etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD docker/files/etc/init.d/unicorn /etc/init.d/unicorn
RUN chmod +x /etc/init.d/unicorn
<% elsif ENV['ROLE'] == 'job' %>
ADD docker/files/etc/supervisor/conf.d/sidekiq.conf /etc/supervisor/conf.d/sidekiq.conf
ADD docker/files/etc/init.d/sidekiq /etc/init.d/sidekiq
RUN chmod +x /etc/init.d/sidekiq
<% end %>

CMD ["/bin/sh", "/var/www/app/script/run-supervisord.sh"]
```

`COPY . $RAILS_ROOT` でプロジェクトディレクトリをコピーするまでは、

```bash
RUN echo <%= `cat docker/files/etc/supervisor/supervisord.conf`.inspect %> > \
  /etc/supervisor/supervisord.conf
```

の様に、`ADD` コマンドを使わず、ビルド時に更新タイムスタンプを元に更新の有無を見ているため、
キャッシュが無効になり、毎回ビルドが走ってしまうのを回避しています。

![](visualize-images.png)

## Docker Image をビルドする

![](build-docker-image.png)

上記の `Dockerfile.erb` をレンダリングして、`docker build` コマンドを実行します。

```bash
ROLE=web ./script/build-docker.sh
```

### build-docker.sh

```bash
#!/bin/sh
set -eu

erb Dockerfile.erb > Dockerfile
docker build -t "${DOCKER_REPO}:${ROLE}" .
```

## [Serverspec] でビルドした Image をテストする

![](serverspec.png)

テスト用の MySQL, Redis のイメージを Pull し、デーモン起動しておきます。

```bash
docker pull redis
docker pull mysql
docker run --name dev-redis -d redis
docker run --name dev-mysql -e 'MYSQL_ROOT_PASSWORD=dev' -d mysql
```

スクリプトを実行します

```
TARGET=${DOCKER_REPO}:web ./script/run-server-spec.sh
```

### run-server-spec.sh

```bash
#!/bin/sh
set -eu

HASH=$(openssl rand -hex 4)
DATABASE_URL=mysql2://root:dev@dev-mysql/docker-rails-example
REDIS_URL=redis://dev-redis:6379/dev

docker run \
  -e DATABASE_URL="${DATABASE_URL}" \
  -e REDIS_URL="${REDIS_URL}" \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  --name "dbmigrate-${HASH}" \
  -w /var/www/app -t $TARGET \
  sh -c './bin/rake db:create; ./bin/rake db:migrate:reset'

docker run \
  -e DATABASE_URL="${DATABASE_URL}" \
  -e REDIS_URL="${REDIS_URL}" \
  -v "$(pwd)/docker/serverspec"\:/mnt/serverspec \
  --name "serverspec-${HASH}" \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  -w /mnt/serverspec -t $TARGET \
  sh -c 'echo "DATABASE_URL=${DATABASE_URL}" >> /var/www/app/.env && echo "REDIS_URL=${REDIS_URL}" >> /var/www/app/.env && service supervisor start && bundle install --path=vendor/bundle && sleep 10 && bundle exec rake spec'

set +eu
[ $CI ] || docker rm "dbmigrate-${HASH}"
[ $CI ] || docker rm "serverspec-${HASH}"
```

最後の2行は、[CircleCI] 上で Docker Container を削除しようとすると、`Failed to destroy btrfs snapshot: operation not permitted` というエラーで失敗するため、ローカル環境など、`CI` 環境変数がセットされていない場合にのみ、Container の削除を行う様にしています。

## [Amazon EC2 Container Service] にデプロイ

前途のとおり、`db:migrate` 用のタスクを作成し、常駐プロセスが起動する、Task を Service に設定します。

```bash
export ENV_NAME=`echo $CIRCLE_BRANCH | sed 's/deployment\///'` && \
/bin/sh script/ecs-deploy-db-migrate.sh && \
sleep 5 && \
/bin/sh script/ecs-deploy-services.sh
```

Task Definition の Erb テンプレートをレンダリングして、実行中のビルド固有のタスクを定義します。

本番環境用の Redis, MySQL の URL を、予め `_PRODUCTION` の接尾辞を付けて環境変数に設定していたものから取得し、この定義ファイルに、`REDIS_URL`, `DATABASE_URL` として上書きする記述を行います。

### ecs-deploy-db-migrate.sh

`rake db:migrate` を実行するタスクを作成します。

```bash
#!/bin/sh
set -eu

CLUSTER=default
UPPER_ENV_NAME=$(echo $ENV_NAME | awk '{print toupper($0)}')
DATABASE_URL=$(eval "echo \$DATABASE_URL_${UPPER_ENV_NAME}")
REDIS_URL=$(eval "echo \$REDIS_URL_${UPPER_ENV_NAME}")
APP_NAME='ngs-docker-rails-example-'
TASK_FAMILY="${APP_NAME}db-migrate-${ENV_NAME}"

REDIS_URL=$REDIS_URL DATABASE_URL=$DATABASE_URL \
  erb ecs-task-definitions/task-db-migrate.json.erb > .ecs-task-definition.json
TASK_DEFINITION_JSON=$(aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "file://$(pwd)/.ecs-task-definition.json")
TASK_REVISION=$(echo $TASK_DEFINITION_JSON | jq .taskDefinition.revision)

aws ecs run-task --cluster ${CLUSTER} --task-definition "${TASK_FAMILY}:${TASK_REVISION}" | jq .
```

### task-db-migrate.json.erb

```json
{
  "family": "ngs-docker-rails-example-db-migrate-<%= ENV['ENV_NAME'] %>",
  "containerDefinitions": [
    {
      "image": "<%= ENV['DOCKER_REPO'] %>:job-b<%= ENV['CIRCLE_BUILD_NUM'] %>",
      "name": "docker-rails-example-db-migrate",
      "cpu": 1,
      "memory": 128,
      "essential": true,
      "command": ["./bin/rake", "db:migrate"],
      "mountPoints": [{ "containerPath": "/var/www/app/log", "sourceVolume": "log", "readOnly": false }],
      "environment": [
        { "name": "DATABASE_URL", "value": "<%= ENV['DATABASE_URL'] %>" },
        { "name": "REDIS_URL", "value": "<%= ENV['REDIS_URL'] %>" }
      ],
      "essential": true
    }
  ],
  "volumes": [
    {
      "name": "log",
      "host": { "sourcePath": "/var/log/rails" }
    }
  ]
}
```

### ecs-deploy-services.sh

`web`, `job` の常駐プロセスのあるタスクを定義し、サービスを更新、古いタスクを停止します。

```bash
#!/bin/sh
set -eu

CLUSTER=default
UPPER_ENV_NAME=$(echo $ENV_NAME | awk '{print toupper($0)}')
DATABASE_URL=$(eval "echo \$DATABASE_URL_${UPPER_ENV_NAME}")
REDIS_URL=$(eval "echo \$REDIS_URL_${UPPER_ENV_NAME}")
APP_NAME='ngs-docker-rails-example-'
TASK_FAMILY="${APP_NAME}${ENV_NAME}"
SERVICE_NAME="${APP_NAME}service-${ENV_NAME}"

REDIS_URL=$REDIS_URL DATABASE_URL=$DATABASE_URL \
  erb ecs-task-definitions/service.json.erb > .ecs-task-definition.json
TASK_DEFINITION_JSON=$(aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "file://$(pwd)/.ecs-task-definition.json")
TASK_REVISION=$(echo $TASK_DEFINITION_JSON | jq .taskDefinition.revision)
DESIRED_COUNT=$(aws ecs describe-services --services $SERVICE_NAME | jq '.services[0].desiredCount')

if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="1"
fi

SERVICE_JSON=$(aws ecs update-service --cluster ${CLUSTER} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT})
echo $SERVICE_JSON | jq .

TASK_ARN=$(aws ecs list-tasks --cluster ${CLUSTER} --service ${SERVICE_NAME} | jq -r '.taskArns[0]')
TASK_JSON=$(aws ecs stop-task --task ${TASK_ARN})
echo $TASK_JSON | jq .
```

### service.json.erb

```json
{
  "family": "ngs-docker-rails-example-<%= ENV['ENV_NAME'] %>",
  "containerDefinitions": [
    {
      "image": "<%= ENV['DOCKER_REPO'] %>:web-b<%= ENV['CIRCLE_BUILD_NUM'] %>",
      "name": "docker-rails-example-web",
      "cpu": 1,
      "memory": 128,
      "essential": true,
      "portMappings": [{ "hostPort": 80, "containerPort": 80, "protocol": "tcp" }],
      "mountPoints": [{ "containerPath": "/var/www/app/log", "sourceVolume": "log", "readOnly": false }],
      "environment": [
        { "name": "DATABASE_URL", "value": "<%= ENV['DATABASE_URL'] %>" },
        { "name": "REDIS_URL", "value": "<%= ENV['REDIS_URL'] %>" }
      ],
      "essential": true
    },
    {
      "image": "<%= ENV['DOCKER_REPO'] %>:job-b<%= ENV['CIRCLE_BUILD_NUM'] %>",
      "name": "docker-rails-example-job",
      "cpu": 1,
      "memory": 128,
      "essential": true,
      "mountPoints": [{ "containerPath": "/var/www/app/log", "sourceVolume": "log", "readOnly": false }],
      "environment": [
        { "name": "DATABASE_URL", "value": "<%= ENV['DATABASE_URL'] %>" },
        { "name": "REDIS_URL", "value": "<%= ENV['REDIS_URL'] %>" }
      ],
      "essential": true
    }
  ],
  "volumes": [
    {
      "name": "log",
      "host": { "sourcePath": "/var/log/rails" }
    }
  ]
}
```

## WIP

今回記載した内容では、タスクの切り替え時にダウンタイムが発生してしまうので、以下の記事などを参考に、無停止デプロイの設定をしたいと思います。

- [EC2 Container Service (ECS) を管理して、Blue-Green Deploymentを実現するツールを書いた](http://stormcat.hatenablog.com/entry/2015/07/22/130000)

[Serverspec]: http://serverspec.org/
[CircleCI]: https://circleci.com/
[Sidekiq]: http://sidekiq.org/
[nginx]: http://nginx.org/
[unicorn]: http://unicorn.bogomips.org/
[Supervisor]: http://supervisord.org/
[Amazon EC2 Container Service]: https://aws.amazon.com/jp/ecs/
[circle.yml]: https://github.com/ngs/docker-rails-example/blob/master/circle.yml
