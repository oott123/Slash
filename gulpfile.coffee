sourceDir = 'browser/src'
destDir = 'browser/assets'
viewsDir = 'browser'

gulp = require 'gulp'
clean = require 'gulp-clean'
jade = require 'gulp-jade'
less = require 'gulp-less'
coffee = require 'gulp-coffee'

gulp.task 'clean', ->
    gulp.src([destDir, "#{viewsDir}/*.html", tempDir]).pipe(clean())

gulp.task 'html', ->
    gulp.src "#{sourceDir}/jade/**/*.jade"
        .pipe jade()
        .pipe gulp.dest viewsDir

gulp.task 'css', ->
    gulp.src "#{sourceDir}/less/importer.less"
        .pipe less()
        .pipe gulp.dest "#{destDir}/css"

gulp.task 'js', ->
    gulp.src "#{sourceDir}/coffee/**/*.coffee"
        .pipe coffee()
        .pipe gulp.dest("#{destDir}/js")

gulp.task 'static', ->
    gulp.src "#{sourceDir}/static/**"
        .pipe gulp.dest "#{destDir}"

gulp.task 'index-js', ->
    gulp.src "coffee/index.coffee"
        .pipe coffee()
        .pipe gulp.dest ""

gulp.task 'main-js', ['index-js'],->
    gulp.src "coffee/**/*.coffee"
        .pipe coffee()
        .pipe gulp.dest "js/"

gulp.task 'default', ['html', 'static', 'js', 'css', 'main-js'], ->
    # default task

gulp.task 'watch', ['default'], ->
    gulp.watch "#{sourceDir}/coffee/**/*.coffee", ['js']
    gulp.watch "#{sourceDir}/less/**/*.less", ['css']
    gulp.watch "#{sourceDir}/jade/**/*.jade", ['html']
    gulp.watch "#{sourceDir}/static/**/*", ['static']
    gulp.watch "coffee/index.coffee", ['index-js']
    gulp.watch "coffee/**/*.coffee", ['main-js']
