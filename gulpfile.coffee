sourceDir = 'src'
destDir = 'browser/assets'
tempDir = 'gulp-tmp'
viewsDir = 'browser'

gulp = require 'gulp'
clean = require 'gulp-clean'
jade = require 'gulp-jade'
less = require 'gulp-less'
coffee = require 'gulp-coffee'

gulp.task 'clean', ->
    gulp.src([destDir, viewsDir, tempDir]).pipe(clean())

gulp.task 'html', ->
    gulp.src "#{sourceDir}/jade/**/*.jade"
        .pipe jade()
        .pipe gulp.dest(viewsDir)

gulp.task 'css', ->
    gulp.src "#{sourceDir}/less/importer.less"
        .pipe less()
        .pipe gulp.dest("#{tempDir}/")

gulp.task 'js', ->
    gulp.src "#{sourceDir}/coffee/**/*.coffee"
        .pipe coffee()
        .pipe gulp.dest("#{destDir}/js")

gulp.task 'static', ->
    gulp.src "#{sourceDir}/static/**"
        .pipe gulp.dest("#{destDir}")

gulp.task 'default', ['html', 'static', 'js', 'css'], ->
    gulp.src(tempDir).pipe(clean()) #清除临时文件

gulp.task 'watch', ['default'], ->
    gulp.watch "#{sourceDir}/coffee/**/*.coffee", ['js']
    gulp.watch "#{sourceDir}/less/**/*.less", ['css']
    gulp.watch "#{sourceDir}/jade/**/*.jade", ['html']
    gulp.watch "#{sourceDir}/static/**/*", ['static']
