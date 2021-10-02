/*!
 * Gulp SMPL Layout Builder
 *
 * @version 8.1.5
 * @author Artem Dordzhiev (Draft)
 * @type Module gulp
 * @license The MIT License (MIT)
 */

/* Get plugins */
const gulp = require('gulp');
const browserSync = require('browser-sync');
const fs = require('fs');
const glob = require('glob');
const pkg = JSON.parse(fs.readFileSync('./package.json'));
const $ = require('gulp-load-plugins')({pattern: ['gulp-*', 'gulp.*', 'del', 'merge-stream']});
const webpack = require('webpack-stream');
const dotenv = require('dotenv');
const ENV = process.env;

/* Init environment */
dotenv.config();
if (!ENV.NODE_ENV) ENV.NODE_ENV = "development";

/* Helpers */
function getConfig(section) {
    const config = require(`./config.${ENV.NODE_ENV}.js`);
    return section ? config[section] ? config[section] : {} : config;
}

function getLocale(locale) {
    let json = {};
    if (ENV.FORCE_LOCALE) locale = ENV.FORCE_LOCALE;
    if (locale) {
        const files = glob.sync(`./src/locales/${locale}/*.json`);
        if (files.length) files.forEach((file) => Object.assign(json, JSON.parse(fs.readFileSync(file))));
    }
    return json;
}

/* Primary tasks */
gulp.task('default', (done) => {
    gulp.series('build:production')(done)
});

gulp.task('serve', (done) => {
    gulp.series('clean', gulp.parallel('sprites', 'svgsprites'), gulp.parallel('sass', 'js'), 'pug', 'browsersync', 'watch')(done)
});

gulp.task('build', (done) => {
    gulp.series('clean:dist', gulp.parallel('sprites', 'svgsprites'), gulp.parallel('sass', 'js', 'copy:static'), 'pug')(done)
});

gulp.task('build:production', (done) => {
    ENV.NODE_ENV = "production";
    gulp.series('clean:dist', gulp.parallel('sprites', 'svgsprites'), gulp.parallel('sass', 'js', 'copy:static'), 'pug')(done)
});

/* Pug task */
gulp.task('pug', () => {
    const config = getConfig('pug');
    const locale = getLocale(config.locale);
    const pugOptions = Object.assign({}, {
        basedir: "./src/pug/",
        locals: {
            "fs": fs,
            "ENV": ENV,
            "NODE_ENV": ENV.NODE_ENV,
            "PACKAGE": pkg,
            "__": locale
        }
    }, config.pugOptions);

    if (config.templates) {
        config.templates.forEach((tmp) => {
            const iterate = tmp.iterate || {};
            const arr = typeof (iterate) === "string" ? iterate.split('.').reduce((p, i) => p[i], locale) : iterate;
            Object.keys(arr).map((key) => {
                gulp.src(tmp.src)
                    .pipe($.plumber())
                    .pipe($.pug({...pugOptions, data: {"$": key}}))
                    .pipe($.rename({basename: tmp.basename.replace('$', key), dirname: tmp.dirname.replace('$', key)}))
                    .pipe($.if(!!config.ext, $.rename({extname: config.ext})))
                    .pipe(gulp.dest(config.dest));
            });
        });
    }

    return gulp.src(['./src/pug/**/*.pug', '!./src/pug/_includes/**/*'])
        .pipe($.plumber())
        .pipe($.pug(pugOptions))
        .pipe($.if(!!config.ext, $.rename({extname: config.ext})))
        .pipe(gulp.dest(config.dest)).on('end', () => {
            browserSync.reload();
        });
});

/* Sass task */
gulp.task('sass', () => {
    const config = getConfig('sass');

    return gulp.src('./src/scss/main.scss')
        .pipe($.if(config.maps, $.sourcemaps.init()))
        .pipe($.sass(config.sassOptions))
        .pipe($.if(config.autoprefixer, $.autoprefixer(config.autoprefixerOptions)))
        .pipe($.if(config.rtl, $.rtlcss()))
        .pipe($.if(config.cleanCss, $.cleanCss(config.cleanCssOptions)))
        .pipe($.if(config.maps, $.sourcemaps.write('.')))
        .pipe(gulp.dest(config.dest))
        .pipe(browserSync.stream({match: '**/*.css'}));
});

/* JS (webpack) task */
gulp.task('js', (done) => {
    const config = getConfig('js');

    return gulp.src(['./src/js/**/*'])
        .pipe(webpack(require(`./webpack.${ENV.NODE_ENV}.js`)))
        .pipe(gulp.dest(config.dest));
});

/* Icon tasks */
gulp.task('svgsprites', (done) => {
    if (!fs.existsSync('./src/icons/') && !done()) return false;
    const config = getConfig('svgsprites');
    const svgSpriteOptions = {
        mode: {
            symbol: {
                dest: "assets/img/sprites/",
                sprite: "svgsprites.svg",
                render: {
                    scss: {
                        dest: '../../../../src/scss/generated/svgsprites.scss',
                        template: "./src/scss/templates/svgsprites.handlebars"
                    }
                }
            }
        }
    };

    return gulp.src('./src/icons/*.svg')
        .pipe($.svgSprite(svgSpriteOptions))
        .pipe(gulp.dest(config.dest));
});

gulp.task('sprites', (done) => {
    if (!fs.existsSync('./src/sprites/') && !done()) return false;
    const config = getConfig('sprites');
    const spriteData = gulp.src('./src/sprites/**/*.png').pipe($.spritesmith({
        imgPath: '../img/sprites/sprites.png',
        imgName: 'sprites.png',
        retinaImgPath: '../img/sprites/sprites@2x.png',
        retinaImgName: 'sprites@2x.png',
        retinaSrcFilter: ['./src/sprites/**/**@2x.png'],
        cssName: 'sprites.scss',
        cssTemplate: "./src/scss/templates/sprites.handlebars",
        padding: 1
    }));

    const imgStream = spriteData.img
        .pipe(gulp.dest(config.dest));

    const cssStream = spriteData.css
        .pipe(gulp.dest('./src/scss/generated'));

    return $.mergeStream(imgStream, cssStream);
});

/* Browsersync Server */
gulp.task('browsersync', (done) => {
    const config = getConfig('browserSync');
    const options = Object.assign({}, {
        server: config.dest
    }, config);

    browserSync.init(options);
    done();
});

/* Watcher */
gulp.task('watch', () => {
    gulp.watch("./src/scss/**/*.scss", gulp.series('sass'));
    gulp.watch("./src/pug/**/*.pug", gulp.series('pug'));
    gulp.watch("./src/locales/**/*.json", gulp.series('pug'));
    gulp.watch("./src/js/**/*.*", gulp.series('js'));
    gulp.watch("./src/icons/**/*.svg", gulp.series('svgsprites'));
    gulp.watch(`./config.${ENV.NODE_ENV}.js`, gulp.parallel('pug', 'js'));
    gulp.watch(`./webpack.${ENV.NODE_ENV}.js`, gulp.series('js'));
});

/* FS tasks */
gulp.task('clean', () => {
    return $.del(['./tmp/**/*'], {dot: true});
});

gulp.task('clean:dist', () => {
    return $.del(['./dist/**/*'], {dot: true});
});

gulp.task('copy:static', () => {
    return gulp.src(['./src/static/**/*'], {dot: true})
        .pipe(gulp.dest('./dist/'));
});
