/* eslint-env node */

var gulp = require('gulp');
var webpack = require('webpack-stream');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var vulcanize = require('gulp-vulcanize');
var replace = require('gulp-replace');

gulp.task('webpack', function() {
	return gulp.src('components/resume.js')
		.pipe(webpack(
			{ output: { filename: 'scripts.js' }
			, module:
				{ loaders: [ { loader: 'babel-loader' } ] }
			, devtool: 'sourcemap-loader'
			}))
		.pipe(gulp.dest('dist/'));
});

gulp.task('minify', function() {
	return gulp.src('dist/scripts.js')
		.pipe(uglify())
		.pipe(rename('scripts.min.js'))
		.pipe(gulp.dest('dist/'));
});

gulp.task('vulcanize', ['webpack'], function() {
	return gulp.src('index.html')
		.pipe(vulcanize(
			{ inlineScripts: false
			, inlineCss: true
			}))
		.pipe(replace(/"dist\/scripts\.js"/, '"scripts\.min.js"'))
		.pipe(gulp.dest('dist/'))
		.pipe(replace(/"scripts\.min\.js"/, '"scripts.js"'))
		.pipe(rename('index-debug.html'))
		.pipe(gulp.dest('dist/'));
});

gulp.task('copy-images', function() {
	return gulp.src('images/**')
		.pipe(gulp.dest('dist/images'));
});
