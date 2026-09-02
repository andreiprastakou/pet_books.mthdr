const { config } = require('shakapacker')
const buildConfigWithEnginesAndLegacyPlugins = require('./engine_and_legacy_plugins')

const developmentEnvOnly = (clientConfig) => {
  // React Refresh (Fast Refresh) setup - only when dev server is running (HMR mode)
  if (!process.env.WEBPACK_SERVE) return

  // eslint-disable-next-line global-require
  if (config.assets_bundler === 'rspack') {
    // Rspack uses @rspack/plugin-react-refresh for React Fast Refresh
    const ReactRefreshPlugin = require('@rspack/plugin-react-refresh')
    clientConfig.plugins.push(new ReactRefreshPlugin())
  } else {
    // Webpack uses @pmmmwh/react-refresh-webpack-plugin
    const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin')
    clientConfig.plugins.push(
      new ReactRefreshWebpackPlugin({
        // Use default overlay configuration for better compatibility
      }),
    )
  }
}

/**
 * Shakapacker's base config enables `splitChunks: { chunks: 'all' }`, which names the
 * resulting vendor chunks after the modules they contain (e.g.
 * `vendors-node_modules_fortawesome_free-regular-svg-icons_faBookmark_js-…-33eb29.js`).
 * Adding or removing a single import reshuffles those chunks, so the filenames listed in
 * `manifest.json` change on almost every edit. The dev server only keeps the current
 * build in memory, so any page still holding the previous filenames requests assets that
 * no longer exist. Entry-level splitting only matters for production caching, so keep
 * development on the stable `runtime.js` + `<entry>.js` pair.
 */
const stableDevelopmentChunkNames = clientConfig => {
  clientConfig.optimization.splitChunks = false
}

const configForDevelopment = buildConfigWithEnginesAndLegacyPlugins()
stableDevelopmentChunkNames(configForDevelopment)
developmentEnvOnly(configForDevelopment)

module.exports = configForDevelopment
