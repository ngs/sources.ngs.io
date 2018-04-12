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
