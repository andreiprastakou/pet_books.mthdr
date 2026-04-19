const { merge } = require('webpack-merge')
const webpack = require('webpack')
const environment = require('./environment')
const clientWebpackConfig = require('./clientWebpackConfig')

/**
 * Webpacker (`environment.js`) adds engine entry points (`admin`, `frontend`) and
 * helpers like ProvidePlugin for jQuery. Shakapacker supplies the Webpack 5 config.
 *
 * We do not merge the full `environment.toWebpackConfig()` output: Webpacker’s legacy
 * `node` polyfill fields are invalid under Webpack 5’s schema when naïvely merged.
 * Instead we splice in engine entries and Webpacker-only plugins onto the Shakapacker base.
 */
function mergeWebpackerAndShakapacker() {
  const shaka = clientWebpackConfig()
  const webpacker = environment.toWebpackConfig()

  const engineEntries = {}
  if (webpacker.entry?.admin) engineEntries.admin = webpacker.entry.admin
  if (webpacker.entry?.frontend) engineEntries.frontend = webpacker.entry.frontend

  const provideFromWebpacker = (webpacker.plugins || []).filter(
    (p) => p instanceof webpack.ProvidePlugin
  )

  const merged = merge(shaka, { entry: engineEntries })
  merged.plugins = [...(merged.plugins || []), ...provideFromWebpacker]

  return merged
}

module.exports = mergeWebpackerAndShakapacker
