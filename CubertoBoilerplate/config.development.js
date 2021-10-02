module.exports = {
	pug: {
		dest : "./tmp/",
		locale: "en",
		ext: false,
		pugOptions: {
			pretty: false
		}
	},
	sass: {
		dest: "./tmp/assets/css/",
		maps: true,
		autoprefixer: true,
		rtl: false,
		cleanCss: false,
		sassOptions: {
			includePaths: "node_modules"
		}
	},
	js: {
		dest: "./tmp/assets/js"
	},
	svgsprites: {
		dest: "./tmp/"
	},
	sprites: {
		dest: "./tmp/assets/img/sprites/"
	},
	browserSync: {
		dest: ["./tmp", "./src/static"],
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
