---
title: Fetch distributions and invalidate with hubot-cloudfront
description: I published a Hubot script to fetch Amazon CloudFront distribution list and invalidate objects.
date: 2014-06-28 21:00
public: true
tags: aws, amazon, cloudfront, middleman, hubot, script, hipchat, kaizenplatform
alternate: true
ogp:
  og:
    image:
      '': 2014-06-28-hubot-cloudfront/hipchat.png
      type: image/png
      width: 1716
      height: 1048
---

![](2014-06-28-hubot-cloudfront/hipchat.png)

I published a [Hubot] script to fetch [Amazon CloudFront] distribution list and invalidate objects.

**[ngs/hubot-cloudfront]**

```sh
npm install --save hubot-cloudfront
```

READMORE

List Distributions
------------------

Lists distributions with ID, domain name, status, comment and number of invalidation batches (if exists).

```
me > hubot cloudfront list distributions
hubot > - 0: E2SO336F6AMQ08 --------------------
          domain: d1ood20dgya2ll.cloudfront.net
          status: InProgress
          comment: Distribution for static.liap.us

        - 1: E29XRZTZN1VOAV --------------------
          domain: d290rn73xc4vfg.cloudfront.net
          status: Deployed
          invalidation batches in progress: 10
```


Shortcut:

```
me > hubot cf ls dist
```


Create invalidations
--------------------

```
me > hubot cloudfront invalidate E2SO336F6AMQ08 /index.html /atom.xml /javascripts/*.js
hubot > Invalidation I14NJQR76VVQAT on distribution E29XRZTZN1VOAV created.
        It might take 10 to 15 minutes until all files are invalidated.
```


You can use either ID and 0-based index number (on the left of distribution ID) to specify distribution.

```
me > hubot cloudfront invalidate 0 /index.html /atom.xml /javascripts/*.js
```


Shortcut:

```
me > hubot cf inv 0 /index.html /atom.xml /javascripts/*.js
```


After creating invalidations, [Hubot] checks every 1 minute and notifies if completed.

```
hubot > @ngs Invalidation I14NJQR76VVQAT on distribution E29XRZTZN1VOAV completed.
```


List invalidations
------------------

List distribution with ID or 0-based index number.

```
me > hubot cloudfront list invalidates E2SO336F6AMQ08
hubot > I14NJQR76VVQAT - InProgress
        I3MAZE9OBGZ05X - Completed
```


Shortcut:

```
me > hubot cf ls inv 0
```


[Amazon S3]: http://aws.amazon.com/s3/
[Amazon CloudFront]: http://aws.amazon.com/cloudfront/
[ngs/hubot-cloudfront]: https://github.com/ngs/hubot-cloudfront
[Hubot]: https://hubot.github.com/
