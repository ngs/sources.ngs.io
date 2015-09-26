---
title: "CircleCI で Docker Container を Serverspec でテストする"
description: "現在構築中のサービスの Rails アプリケーションのインフラとして、Amazon EC2 Container Service (ECS) を採用し、自動化を頑張ってみた内容を公開します。"
date: 2015-09-26 09:30
public: true
tags: docker, infrastructure, circleci, go, serverspec
alternate: false
ogp:
  og:
    image:
      '': http://ja.ngs.io/images/2015-09-26-circleci-docker-serverspec/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2015-09-26-circleci-docker-serverspec/main.jpg)

[Serverspec] の Docker Backend を使った Docker コンテナのテストを [CircleCI] 上で実行する際、多少手こずったので、その試行錯誤によってできた、サンプルプロジェクトを公開しました。

- [GitHub Repository](https://github.com/ngs/docker-serverspec-circleci-example)
- [quay.io Registry](https://quay.io/repository/atsnngs/docker-serverspec-circleci-example)
- [CircleCI Builds](https://circleci.com/gh/ngs/docker-serverspec-circleci-example/tree/master)

READMORE

[前回の記事](http://ja.ngs.io/2015/09/14/ecs-docker-rails/)で紹介した事例は Rails を採用していたので、コンテナ側にも Ruby がインストールされており、コンテナ側にマウントするだけで [Serverspec] を実行できました。

```sh
docker run \
  -e DATABASE_URL="${DATABASE_URL}" \
  -e REDIS_URL="${REDIS_URL}" \
  -v "$(pwd)/docker/serverspec"\:/mnt/serverspec \
  --name "serverspec-${HASH}" \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  -w /mnt/serverspec -t $TARGET \
  sh -c 'echo "DATABASE_URL=${DATABASE_URL}" >> /var/www/app/.env &&
  echo "REDIS_URL=${REDIS_URL}" >> /var/www/app/.env &&
  service supervisor start &&
  bundle install --path=vendor/bundle &&
  sleep 10 &&
  bundle exec rake spec'
```

今回、新たに Ruby を使わないアプリケーションのコンテナを作る必要があり、コンテナ側には Ruby をインストールせず、ホスト側の Ruby から直接 Severspec を実行すべく、Specinfra の Docker Backend を採用しテストをしようと試みました。

参照: [Specinfra::Backend::Docker](https://github.com/mizzy/specinfra/blob/master/lib/specinfra/backend/docker.rb)

[Serverspec] は Docker の `Exec` コマンドを使用してコンテナ内の処理を行う仕組みになっており、[CircleCI] が Docker のドライバとして採用している LXC は、そ
の `Exec` コマンドに対応していません。

```
Unsupported: Exec is not supported by the lxc driver
```

そのため、[CircleCI のドキュメント](https://circleci.com/docs/docker#docker-exec) に記載されている通り、`lxc-attach` コマンドを使って直接コンテナ側と IO のやり取りをする必要がありました。

```sh
sudo lxc-attach -n "$(docker inspect --format '{{.Id}}' $MY_CONTAINER_NAME)" -- bash -c $MY_COMMAND
```

現時点では Docker Backend ないしは、その依存ライブラリで `lxc-attach` に処理を行わせる機構がないため、
モンキーパッチを [spec_helper.rb] に実装しました。

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
        command[2] = command[2].inspect # ['/bin/sh', '-c', 'YOUR COMMAND']
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

以下は [circle.yml] の抜粋です。`test.pre` であらかじめ `serverspec` という名前のコンテナを立ち上げておき、環境変数でコンテナ名を指定して `rspec` を実行します。

```yaml
test:
  pre:
    - docker run --name serverspec -p 8080:8080 -d $DOCKER_REPO && sleep 5
  override:
    - bundle exec rspec:
        pwd: docker/serverspec
        environment:
          DOCKER_CONTAINER: serverspec
```

## その他試したこと

上記の方法でテストを成功させる前に、以下の試行を行いました。

### Specinfra のバージョンを古いもので固定する

参照:

- [CircleCIでDockerコンテナをテストしようとしたらエラーになるとき](http://qiita.com/honeniq/items/00504fecc708f9026bc5)
- [Test Docker Images with circleci](https://workshop.avatarnewyork.com/post/test-docker-images-with-circleci/)

以下のエラーでコケました。

```
undefined method `gsub' for nil:NilClass
```

- [Build #20](https://circleci.com/gh/ngs/docker-serverspec-circleci-example/20)
- [Commit `c950d13`](https://github.com/ngs/docker-serverspec-circleci-example/commit/c950d13f731b7eb8c7493bb883ff31f890d7d867)

### Specinfra LXC Backend を採用する

lxc-extra gem のビルドでコケたので、諦めました。

- [Build #21](https://circleci.com/gh/ngs/docker-serverspec-circleci-example/21)
- [Commit `746a9ad`](https://github.com/ngs/docker-serverspec-circleci-example/commit/746a9ad05d9f974e356df152a2ea06c74c91196e)

[spec_helper.rb]: https://github.com/ngs/docker-serverspec-circleci-example/blob/master/docker/serverspec/spec/spec_helper.rb
[circle.yml]: https://github.com/ngs/docker-serverspec-circleci-example/blob/master/circle.yml
[CircleCI のドキュメント]: https://circleci.com/docs/docker#docker-exec
[Serverspec]: http://serverspec.org/
[Specinfra]: https://github.com/mizzy/specinfra
[CircleCI]: https://circleci.com/
