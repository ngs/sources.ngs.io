---
title: "CircleCI で Docker Container を Serverspec する"
description: "現在構築中のサービスの Rails アプリケーションのインフラとして、Amazon EC2 Container Service (ECS) を採用し、自動化を頑張ってみた内容を公開します。"
date: 2015-09-26 07:45
public: true
tags: docker, infrastructure, circleci, go, serverspec
alternate: false
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2015-09-14-ecs-docker-rails/build-docker-image.png
      type: image/png
      width: 992
      height: 525
---

Serverspec の Docker ドライバを使ったテストを CircleCI 上で実行する際、多少手こずったので、その試行錯誤によってできた、サンプルプロジェクトを公開しました。

- [GitHub Repository](https://github.com/ngs/docker-serverspec-circleci-example)
- [quay.io Registry](https://quay.io/repository/atsnngs/docker-serverspec-circleci-example)
- [CircleCI Builds](https://circleci.com/gh/ngs/docker-serverspec-circleci-example/tree/master)

READMORE

## コンテナ側の Ruby で Serverspec を実行していた

[前回の記事](http://ja.ngs.io/2015/09/14/ecs-docker-rails/)で紹介した事例は Rails を採用していたので、コンテナ側にも Ruby がインストールされており、コンテナ側にマウントするだけで Serverspec を実行できました。

```sh
docker run \
  -e DATABASE_URL="${DATABASE_URL}" \
  -e REDIS_URL="${REDIS_URL}" \
  -v "$(pwd)/docker/serverspec"\:/mnt/serverspec \
  --name "serverspec-${HASH}" \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  -w /mnt/serverspec -t $TARGET \
  sh -c 'echo "DATABASE_URL=${DATABASE_URL}" >> /var/www/app/.env && echo "REDIS_URL=${REDIS_URL}" >> /var/www/app/.env && service supervisor start && bundle install --path=vendor/bundle && sleep 10 && bundle exec rake spec'
```

## Ruby をコンテナにインストールしない

今回、新たに Ruby を使わないアプリケーションのコンテナを作る必要があり、コンテナ側には Ruby をインストールせず、ホスト側の Ruby から直接 Severspec を実行すべく、Specinfra の Docker ドライバを採用しテストをしようと試みました。

Serverspec は Docker の Exec コマンドを使用してコンテナ内の処理を行う仕組みになっており、CircleCI が Docker のドライバとして採用している lxc は、その Exec コマンドに対応していないため、[CircleCI のドキュメント](https://circleci.com/docs/docker#docker-exec) に記載されている通り、`lxc-attach` コマンドを使って直接コンテナ側と IO のやり取りをする必要がありました。

```sh
sudo lxc-attach -n "$(docker inspect --format '{{.Id}}' $MY_CONTAINER_NAME)" -- bash -c $MY_COMMAND
```

現時点では Docker ドライバないしは、その依存ライブラリで `lxc-attach` に処理を行わせる機構がないため、モンキーパッチを spec_helper に実装しました。

```rb
require 'serverspec'
require 'docker'
require 'open3'

set :backend, :docker
set :os, family: 'ubuntu', arch: 'x86_64'
if ENV['DOCKER_IMAGE']
  set :docker_image, ENV['DOCKER_IMAGE']
elsif ENV['DOCKER_CONTAINER']
  set :docker_container, ENV['DOCKER_CONTAINER']
end
# TODO https://github.com/swipely/docker-api/issues/202
Excon.defaults[:ssl_verify_peer] = false
# https://circleci.com/docs/docker#docker-exec
if ENV['CIRCLECI']
  module Docker
    class Container
      def exec(command, opts = {}, &block)
        command[2] = command[2].inspect
        cmd = %Q{sudo lxc-attach -n #{self.id} -- #{command.join(' ')}}
        stdin, stdout, stderr, wait_thread = Open3.popen3 cmd
        [stdout.read, [stderr.read], wait_thread.value.exitstatus]
      end
      def remove(options={})
        # do not delete container
      end
      alias_method :delete, :remove
      alias_method :kill, :remove
    end
  end
end
```

