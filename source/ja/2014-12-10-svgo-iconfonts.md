---
title: SVG からフォントを作成する際の元データ最適化
description: SVG からフォントを作成する際、元データを svgo で最適化する意味があるか確認しました。
date: 2014-12-10 21:00
public: true
tags: icon, svg, font, webfont, gulp
alternate: false
ogp:
  og:
  image:
    '': https://raw.github.com/gulpjs/artwork/master/gulp-2x.png
    type: image/png
    width: 228
    height: 510
---

[gulp-iconfont] を使って SVG からフォントを作成する際、元データを [svgo] で最適化する意味があるか確認しました。

100個のアイコンデータの、最適化前後のフォントを作成し、比較しました。

結果、各フォーマット、大差はなかったですが、若干サイズダウンできたので、`gulp` タスクに組み込みました。

READMORE

## SVG 最適化

元データは Adobe Illustrator の保存機能で書き出しただけの SVG ファイルです。

SVG ファイルは 40 から 70% の圧縮率、まちまちでした。複雑なシェイプだと、圧縮率が高かったです。

```
uE001-0001.svg:
Done in 15 ms!
0.653 KiB - 68.5% = 0.206 KiB
```


## フォントファイル比較

[README] に書いてあるのと、ほぼそのままの設定で、書き出し、サイズを比較しました。

### 最適化前

```
14288 KaizenIcons.eot
89694 KaizenIcons.svg
14108 KaizenIcons.ttf
 2200 KaizenIcons.woff
```

### 最適化後

```
14160 KaizenIcons.eot
86206 KaizenIcons.svg
13980 KaizenIcons.ttf
 2192 KaizenIcons.woff
```

かなり微々たる差ですが、一応サイズダウンしている様です。

## gulp タスクで自動化

敢えてやらない理由もないので、`gulp` タスクで自動的に最適化する様に設定しました。

関係する資材のレイアウトは以下の様になっています。`gulpfile.coffee` から `gulp.d/tasks/*.coffee` をロードしています。

```
.
├── assets
|   ├── iconfonts
|   │   ├── uE001-0001.svg ...
|   │   └── paths.coffee
├── configs
│   └── paths.coffee
├── gulpfile.coffee
└── gulp.d
│   └── tasks
│       └── iconfonts.coffee
└── iconfonts.coffee
```

最適化には [gulp-imagemin] を使います。

```coffee
iconfont = require 'gulp-iconfont'
imagemin = require "gulp-imagemin"
consolidate = require 'gulp-consolidate'
paths = require '../configs/paths'
fontName = 'KaizenIcons'

module.exports = (gulp) ->
  gulp.task 'iconfonts', ->
    gulp
    .src "#{paths.iconfonts}/*.svg"
    .pipe imagemin()
    .pipe gulp.dest paths.iconfonts
    .pipe iconfont
      fontName: fontName
      appendCodepoints: yes
      normalize: yes
      fontHeight: 500
    .on 'codepoints', (codepoints, options) ->
      gulp
      .src "#{paths.iconfonts}/templates/_icons.scss"
      .pipe consolidate 'lodash',
        glyphs: codepoints
        fontName: fontName
        fontPath: '../fonts/'
        className: 'kzicon'
      .pipe gulp.dest "#{paths.assets}/styles/object/component"
      .pipe gulp.dest "#{paths.assets}/fonts"
```

[svgo]: https://github.com/svg/svgo
[gulp-iconfont]: https://github.com/nfroidure/gulp-iconfont
[gulp-imagemin]: https://github.com/sindresorhus/gulp-imagemin
[README]: https://github.com/nfroidure/gulp-iconfont#make-your-css
