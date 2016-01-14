'use strict';

let gulp = require('gulp')
  , webpack = require('webpack-stream')
  , less = require('gulp-less')
  , named = require('vinyl-named')
  ;

const DEST = '_site';

gulp.task('webpack', (done) =>
	gulp.src([ 'scripts/splash.ts'
	         ])
	.pipe(named())
	.pipe(webpack(
		{ devtool: 'hidden-source-map'
		, module:
			{ loaders:
				[ { exclude: /node_modules/
				  , loader: 'ts-loader'
				  , test: /\.ts$/
				  }
				, { exclude: /node_modules/
				  , loader: 'babel'
				  , test: /\.js$/
				  }
				]
			}
		}))
	.on('error', done)
	.pipe(gulp.dest(DEST))
);

gulp.task( 'less', (done) => {
	return gulp.src(['less/**/*'])
               .pipe(named())
               .pipe(less())
		       .on('error', done)
               .pipe(gulp.dest(DEST));
});

gulp.task('default', ['webpack', 'less']);

gulp.task('watch-less', () => gulp.watch('less/**/*', ['less']));
gulp.task('watch-js', () => gulp.watch('scripts/**/*', ['webpack']));
gulp.task('watch', ['watch-less', 'watch-js']);
