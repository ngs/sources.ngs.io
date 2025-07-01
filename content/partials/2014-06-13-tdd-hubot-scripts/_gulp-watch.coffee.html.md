gulp.task 'watch', ->
  gulp.src(['src/**/*.coffee', 'spec/*.coffee'])
    .pipe watch(files)->
      files
        .pipe(coffee(bare: yes)
          .pipe(mocha reporter: process.env.MOCHA_REPORTER || 'nyan')
          .on('error', -> @emit 'end'))
