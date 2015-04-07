sources.ngs.io
==============

Blog Sources: [日本語] / [English]

Build & Dependency Status
-------------------------

[![Circle CI](https://circleci.com/gh/ngs/sources.ngs.io/tree/master.svg?style=svg&circle-token=9e64722a06c4c42c0d0205e170215a63ef7b59b7)](https://circleci.com/gh/ngs/sources.ngs.io/tree/master) 
[![Dependency Status](https://gemnasium.com/ngs/sources.ngs.io.svg)](https://gemnasium.com/ngs/sources.ngs.io)

Build
-----

```bash
# English blog
MM_LANG=en bundle exec middleman build
# Japanese blog
MM_LANG=ja bundle exec middleman build
```

Preview
-------

```bash
# English blog
MM_LANG=en bundle exec middleman server -p 4567
# Japanese blog
MM_LANG=ja bundle exec middleman server -p 5678
```

Deploy
------

Export GitHub [OAuth Token] to .env.

```
echo "GH_TOKEN=<MY_GITHUB_TOKEN>" > .env
```


```bash
# English blog
MM_LANG=en bundle exec middleman deploy
# Japanese blog
MM_LANG=ja bundle exec middleman deploy
```

License
-------

Copyright (C) 2014 [Atsushi Nagase][English].

All rights reserved with all articles and pictures.

Everything else in [the repository][repo] is MIT licensed.

See [LICENSE.md] for details.

[日本語]: http://ja.ngs.io/
[English]: http://ngs.io/
[repo]: https://github.com/ngs/source.ngs.io/
[OAuth Token]: https://github.com/settings/tokens/new
[LICENSE.md]: https://github.com/ngs/source.ngs.io/blob/master/LICENSE.md
