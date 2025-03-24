const esbuild = require('esbuild');
const { watch } = require('chokidar');
const { sassPlugin } = require('esbuild-sass-plugin');
const postcss = require('postcss');
const autoprefixer = require('autoprefixer');
const tailwindcss = require('@tailwindcss/postcss');

const args = process.argv.slice(2);
const watchChanges = args.includes('--watch');
const deploy = args.includes('--deploy');

const loader = {
  '.ttf': 'file',
  '.otf': 'file',
  '.svg': 'file',
  '.eot': 'file',
  '.woff': 'file',
  '.woff2': 'file'
};

const plugins = [
  sassPlugin({
    async transform(source, resolveDir) {
      const { css } = await postcss(
        autoprefixer,
        tailwindcss('./tailwind.config.js')
      ).process(source, { from: 'css/app.scss' });

      return css;
    }
  })
];

let opts = {
  entryPoints: ['js/app.js'],
  bundle: true,
  target: 'es2017',
  outdir: '../priv/static/assets',
  external: ['/fonts/*', '/images/*'],
  logLevel: 'info',
  loader,
  plugins
};

if (deploy) {
  opts = {
    ...opts,
    minify: true
  };
}

let promise = esbuild.build(opts);

if (watchChanges) {
  const watcher = watch(['../lib/**/*.*ex*', 'js/**/*.js*', 'css/**/*.*css*']);

  watcher.on('change', () => {
    promise.then(() => {
      promise = esbuild.build({ ...opts, sourcemap: 'inline' });
    });
  });
}
