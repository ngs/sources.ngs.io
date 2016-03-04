---
title: "Deploy Swift WebApps on Amazon EC2 Container Services (ECS)"
description: "How to run web applications built with #swiftlang on Amazon EC2 Container Services (ECS)"
date: 2016-03-04 22:50
public: true
tags: circleci, swift, swifton, amazon, aws, ecs
alternate: true
ogp:
  og:
    image:
      '': http://ngs.io/images/2016-03-04-swift-webapp-on-ecs/serverspec.png
      type: image/png
      width: 732
      height: 481
---

## TL;DR

Developing Web applications with Swift is pretty fun :metal:

We can run them on [Amazon EC2 Container Services] and I tried to build light-weight [Docker] image to deploy more faster.

Here is an example project I made, check this out :point_down:

- https://github.com/ngs/Swifton-TodoApp
- https://hub.docker.com/r/atsnngs/docker-swifton-example/
- https://circleci.com/gh/ngs/Swifton-TodoApp

READMORE

## Swift Web Frameworks

Since Swift language became [open source], some web application frameworks come out.

- [Kitsura](https://developer.ibm.com/swift/products/kitura/)
- [Nest](https://github.com/nestproject/Nest)
- [Perfect](http://perfect.org/)
- [Slimane](https://github.com/noppoMan/Slimane)
- [Swifton]

## Swifton

I’m not yet sure about which is the best. But I started trying [Swifton] the Ruby on Rails port of Swift Language.

The interface is pretty easy to understand:

```swift
import Swifton
import Curassow

class MyController: ApplicationController {
	override init() {
		super.init()
		action("index") { request in
			return self.render("Index")
			// renders Index.html.stencil in Views directory
		}
	}
}

let router = Router()
router.get("/", MyController()["index"])

serve { router.respond($0) }
```

## Swifton TodoApp

Swifton has an example Todo app project: [necolt/Swifton-TodoApp]

This has already has a Dockerfile and Heroku configurations (`app.json` and `Procfile`).

This works, so we can get started with this. But I don't want to use Heroku for production and tried to use Amazon EC2 Container Service (ECS) instead.

## Fat Docker Image

As I mentioned above, this project has a Dockerfile and we can build an image to work with ECS.

But the image contains entire depending libraries to build Swift source code in itself. That becomes 326 MB image size and 893.2 MB virtual size.

```
REPOSITORY  TAG     IMAGE ID      CREATED         VIRTUAL SIZE
<none>      <none>  sha256:c35f9  30 seconds ago  893.2 MB
```

![](2016-03-04-swift-webapp-on-ecs/docker-hub-before.png)

ref: https://hub.docker.com/r/atsnngs/docker-swifton-example/tags/

So I tried to build binaries outside of Docker build process and put it on the image with minimum required assets on CircleCI.

## CircleCI Ubuntu 14.04 Trusty Container

I use the Development Snapshot Swift tarball built on Trusty Ubuntu (14.04).

![](2016-03-04-swift-webapp-on-ecs/tarball.png)

So I choose CircleCI's Trusty Container that is provided as public beta.

http://blog.circleci.com/trusty-image-public-beta/

![](2016-03-04-swift-webapp-on-ecs/circle-ci-trusty-container.png)

## Required softwares for continuously building

First of all, we need to install the following softwares to run `swift build`

```sh
sudo apt-get install libicu-dev clang-3.6 jq
# We also need jq to handle awscli response.

sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100
# See: https://goo.gl/hSfhjE
```

## The required assets to run Swifton application

- Swift runtime shared objects: `usr/lib/swift/linux/*.so`
- Application binary
- Stencil view files

So, I ignored unneeded assets with `.dockerignore` file. This can reduce Docker Image build time.

```
MIT-LICENSE
*.swift
README.md
app.json
.*
swift
!swift/usr/lib/swift/linux/*.so
!.build/release/Swifton-TodoApp
serverspec
```

## The Dockerfile

Here is the Dockerfile. Much simpler than the [original]

```sh
FROM ubuntu:14.04
MAINTAINER a@ngs.io

RUN apt-get update && apt-get install -y libicu52 libxml2 curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV APP_DIR /var/www/app
RUN mkdir -p ${APP_DIR}
WORKDIR ${APP_DIR}
ADD . ${APP_DIR}
RUN ln -s ${APP_DIR}/swift/usr/lib/swift/linux/*.so /usr/lib

EXPOSE 8000
CMD .build/release/Swifton-TodoApp
```

With this Dockerfile, I could reduce the image size to 88 MB, virtual size to 245.8 MB (27.5%).

```
REPOSITORY  TAG     IMAGE ID      CREATED         VIRTUAL SIZE
<none>      <none>  sha256:0d31d  30 seconds ago  245.8 MB
```

![](2016-03-04-swift-webapp-on-ecs/docker-hub-after.png)

## Test the Docker Image

I use [Serverspec] to built Docker Images to keep it reliable.

There's some tips (and monkey patches) to run Serverspec for Docker Containers on CircleCI in Japanese, and will be translate to English later.

http://ja.ngs.io/2015/09/26/circleci-docker-serverspec/

I wrote spec for the Todo app like this:

```ruby
require 'spec_helper'

describe port(8000) do
  it { should be_listening }
end

describe command('curl -i -s -H \'Accept: text/html\' http://0.0.0.0:8000/') do
  its(:exit_status) { is_expected.to eq 0 }
  its(:stdout) { is_expected.to contain 'HTTP/1.1 200 OK' }
  its(:stdout) { is_expected.to contain '<h1>Listing Todos</h1>' }
end

1.upto(2) do|n|
  describe command("curl -i -s -H \'Accept: text/html\' http://0.0.0.0:8000/todos -d \'title=Test#{n}\'") do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to contain 'HTTP/1.1 302 FOUND' }
    its(:stdout) { is_expected.to contain 'Location: /todos' }
  end
end

describe command('curl -i -s -H \'Accept: text/html\' http://0.0.0.0:8000/todos') do
  its(:exit_status) { is_expected.to eq 0 }
  its(:stdout) { is_expected.to contain 'HTTP/1.1 200 OK' }
  its(:stdout) { is_expected.to contain '<h1>Listing Todos</h1>' }
  its(:stdout) { is_expected.to contain '<td>Test1</td>' }
  its(:stdout) { is_expected.to contain '<td>Test2</td>' }
  its(:stdout) { is_expected.to contain '<td><a href="/todos/0">Show</a></td>' }
  its(:stdout) { is_expected.to contain '<td><a href="/todos/1">Show</a></td>' }
end
```

![](2016-03-04-swift-webapp-on-ecs/serverspec.png)

## Deploy on ECS

Before deploying applications on ECS, we need to push the Docker Image on Docker Registry.

```sh
$ docker tag $DOCKER_REPO "${DOCKER_REPO}:b${CIRCLE_BUILD_NUM}"
$ docker push "${DOCKER_REPO}:b${CIRCLE_BUILD_NUM}"
```

I won't describe about how to set up ECS environment this article. Please refer [AWS ECS Documentation].

The [deploy script] is executed in deploy phase of build process of the example project.

This script runs the following operations with [AWS Command Line Interface].

- Renders Task Definition JSON from [ERB template].
- Updates or creates task definition and retrieves new revision number like `swifton-example-production:123`
- Updates or creates with new task definition

After deploying it, you can browse the Todo Example App.

![](2016-03-04-swift-webapp-on-ecs/todos.png)

Have fun! Give me feedbacks if you found any.

https://github.com/ngs/Swifton-TodoApp

[Swifton]: https://github.com/necolt/Swifton
[open source]: https://github.com/apple/swift
[original]: https://github.com/necolt/Swifton-TodoApp/blob/master/Dockerfile
[necolt/Swifton-TodoApp]: https://github.com/necolt/Swifton-TodoApp
[Amazon EC2 Container Services]: https://aws.amazon.com/ecs/
[Docker]: https://www.docker.com/
[Serverspec]: http://serverspec.org/
[deploy script]: https://github.com/ngs/Swifton-TodoApp/blob/master/script/ecs-deploy-services.sh
[ERB template]: https://github.com/ngs/Swifton-TodoApp/blob/master/script/ecs-deploy-services.sh
[AWS ECS Documentation]: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_GetStarted.html
[AWS Command Line Interface]: https://aws.amazon.com/cli/
