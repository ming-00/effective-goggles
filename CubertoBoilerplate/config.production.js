module.exports = {
    pug: {
        dest: "./dist/",
        locale: "en",
        ext: false,
        pugOptions: {
            pretty: false
        }
    },
    sass: {
        dest: "./dist/assets/css/",
        maps: false,
        autoprefixer: true,
        rtl: false,
        cleanCss: true,
        sassOptions: {
            includePaths: "node_modules"
        }
    },
    js: {
        dest: "./dist/assets/js"
    },
    svgsprites: {
        dest: "./dist/"
    },
    sprites: {
        dest: "./dist/assets/img/sprites/"
    },
    browserSync: {
        dest: "./dist",
        notify: false,
        ui: false,
        online: false,
        ghostMode: {
            clicks: false,
            forms: false,
            scroll: false
        }
    }
};
