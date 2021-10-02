## Quick start

### Setup

Make sure that you have Node v.11 or above being installed.

```
npm install
```

Copy `.env.default` to `.env` if it present.

### Production

Build an optimized version of app in `/dist/`:

```
gulp build:production
```

or just use:
```
gulp
```

### Development

Deploy app and start browsersync server + watchers:

```
gulp serve
```

### Basic configuration

Build settings located in `config.development.js` or `config.production.js`.

Webpack configuration in `webpack.development.js` or `webpack.production.js`.

Pug locales set by `"locale"` parameter in build config and overrides with `FORCE_LOCALE` environment variable.

Other config files can be applied with `NODE_ENV` environment variable.

### File structure

```bash
├── /dist/                      # Production directory (minified, optimized and compiled files)
└── /src/                       # The source code of the application
    ├── /icons/                 # SVG icons
    ├── /js/                    # JavaScript source
    ├── /locales/               # JSON localizations strings
    ├── /pug/                   # Pug templates
        └── /_includes/         # Pug partials
    ├── /scss/                  # SCSS styles
        └── /templates/         # SCSS templates for generator tasks (icons, sprites, etc..)
        └── /generates/         # Generated styles
    ├── /sprites/               # Sprite raster images
    ├── /static/                # Root of static files (fonts, images, videos, etc..)
├── /tmp/                       # Temporary served files
├── .env                        # Environment variables
├── .editorconfig               # IDE style configuration
├── babel.config                # Babel config
├── config.development.js       # Development build configuration
├── config.production.js        # Production build configuration
├── webpack.development.js      # Webpack development configuration
├── webpack.production.js       # Webpack production configuration
├── package.json                # Project meta and dependencies
```

### Gulp tasks

`gulp serve` deploy the app and start browsersync server + watchers

`gulp build` build the app in `/dist/` with current environment

`gulp build:production` build the app to `/dist/` with force production environment

`gulp pug` compile Pug files

`gulp sass` compile Sass files

`gulp js` build JS with Webpack + Babel

`gulp sprites` compile spritesheet and style based on sprites in `/src/sprites/`

`gulp svgsprite` compile svg spritesheet and style based on images in `/src/icons/`

`gulp copy:static` copy static files from `/src/static/` to `/dist/`

`gulp browsersync` start a browser sync server

`gulp watch` start watching stream

`gulp clean` remove temporary files

`gulp clean:dist` clean the `/dist/` directory

## Advanced configuration

### HTML

Boilerplate use [Pug](https://pugjs.org/).

The following options are available in the build configuration:

| parameter | type | description |
| :--- | :---: | :--- |
| `locale` | `string` | locale used |
| `ext` | `string` | extension of `.html` files  |
| `pugOptions` | `object` | [compiler options](https://pugjs.org/api/reference.html) |

The following data is passed to each template as global variables:

| variable | type | description |
| :--- | :---: | :--- |
| `__` | `object` | current locale data |
| `ENV` | `object` | current environment variables |
| `NODE_ENV` | `string` | current `NODE_ENV` |
| `PACKAGE` | `object` | `package.json` contents |

### Locales

All locales should be stored in `./src/locales/{LANG}/*.json`.

When building, all `.json` from directory with current lang concatenate into one and you can access its content in a pug from object `__`.

Current lang set by `"locale"` parameter in current build config and overrides with `FORCE_LOCALE` environment variable.

### Styles

Boilerplate use [Sass preprocessor](https://sass-lang.com/).

[Autoprefixer](https://github.com/postcss/autoprefixer), [clean-css](https://github.com/jakubpawlowicz/clean-css) and [RTLCSS](https://github.com/MohammadYounes/rtlcss) (disabled by default in config) is also included. Clean-css by default is disabled in development environment to increase assembly speed.

By default entrypoint is `./src/scss/main.scss`.

The following options are available in the build configuration:

| parameter | type | description |
| :--- | :---: | :--- |
| `maps` | `boolean` | use [Sourcemap](https://www.npmjs.com/package/gulp-sourcemaps) |
| `autoprefixer` | `boolean` | use [Autoprefixer](https://github.com/postcss/autoprefixer)  |
| `rtl` | `boolean` | use [RTLCSS](https://github.com/MohammadYounes/rtlcss) |
| `cleanCss` | `boolean` | use [clean-css](https://github.com/jakubpawlowicz/clean-css) |
| `sassOptions` | `object` | [node-sass options](https://github.com/sass/node-sass#options) |
| `cleanCssOptions` | `object` | [clean-css options](https://github.com/jakubpawlowicz/clean-css#constructor-options) |
| `autoprefixerOptions` | `object` | [Autoprefixer options](https://github.com/postcss/autoprefixer#options) |

### SVG Sprites

All svg icons should be stored in `./src/icons/`.

Make sure the shapes do not use a `fill` property, so that you can dynamically change the color.

To directly compile svg spritesheet use:

```
gulp svgsprite
```

Spritesheet stored in:

`{WORKDIR}/assets/img/sprites/svgsprites.svg`.

Svg sprites also generated scss:

`./src/scss/generated/svgsprites.scss`

Make sure to include it in `./src/scss/main.scss`.

To use icon in pug use mixin:
```jade
+svgicon("ICON_NAME", insertinline = true | false)
```

### Sprites

All sprites should be stored in `./src/sprites/`. `@2x` icons are supported.

To directly compile png spritesheet use:

```
gulp sprites
```

Spritesheet stored in:

`{WORKDIR}/assets/img/sprites/sprites.png`.

`{WORKDIR}/assets/img/sprites/sprites@2x.png`.

Sprites also generated scss:

`./src/scss/generated/svgsprites.scss`

Make sure to include it in `./src/scss/main.scss`.

To use sprites in pug:
```jade
.my-sprite.-NAME
```

### JS

All javascript proceed with [webpack](https://webpack.js.org/) + [Babel](https://babeljs.io/).

Webpack config is stored in `./webpack.{NODE_ENV}.js`.

Babel config is stored in `./babel.config.js`.

By default entrypoint is `./src/js/app.js`.

To directly compile js use:

```
gulp js
```

[Read webpack docs](https://webpack.js.org/concepts/).

[Read Babel docs](https://babeljs.io/docs/en/).

### Browsersync

Browsersync creates a small server for the local development with live reload. If  Browsersync detect changes in code, it makes local rebuild and reloads page (complete or partial).

To build project and start local web server use:

```
gulp serve
```

To start only server, without build project, use:

```
gulp browsersync
```

Build configuration can configure browsersync options.

[See Browsersync options](https://browsersync.io/docs).
