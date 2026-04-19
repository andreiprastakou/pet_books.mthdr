const path = require('path')
const { merge } = require('webpack-merge')
const webpack = require('webpack')
const clientWebpackConfig = require('./clientWebpackConfig')

const REACT_TABLE_IN_NODE_MODULES = /[\\/]node_modules[\\/]react-table[\\/]/u

/**
 * Legacy Webpacker behavior: skip react-table inside node_modules for the main JS/SWC rule
 * (see former config/webpack/environment.js nodeModules loader exclude).
 */
function excludeReactTableFromMainJsRules(config) {
  const walk = (rules) => {
    if (!Array.isArray(rules)) return
    for (const rule of rules) {
      if (!rule) continue
      if (rule.oneOf) walk(rule.oneOf)
      if (rule.rules) walk(rule.rules)
      if (!rule.test || !rule.use) continue
      if (!/\.(js|jsx|mjs|ts|tsx)/u.test(String(rule.test))) continue

      if (Array.isArray(rule.exclude)) {
        rule.exclude.push(REACT_TABLE_IN_NODE_MODULES)
      } else if (rule.exclude === undefined) {
        rule.exclude = [REACT_TABLE_IN_NODE_MODULES]
      } else {
        rule.exclude = [rule.exclude, REACT_TABLE_IN_NODE_MODULES]
      }
    }
  }
  walk(config.module && config.module.rules)
}

/**
 * Engine packs (admin, frontend) + jQuery globals + .mjs in node_modules, on top of Shakapacker.
 */
function buildConfigWithEnginesAndLegacyPlugins() {
  const shaka = clientWebpackConfig()

  const engineEntries = {
    admin: path.resolve(__dirname, '../../engines/admin/app/javascript/packs/admin.js'),
    frontend: path.resolve(__dirname, '../../engines/frontend/app/javascript/packs/application.js'),
  }

  const merged = merge(shaka, {
    entry: engineEntries,
    plugins: [
      new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery',
      }),
    ],
    module: {
      rules: [
        {
          test: /\.mjs$/u,
          include: /node_modules/u,
          type: 'javascript/auto',
        },
      ],
    },
  })

  excludeReactTableFromMainJsRules(merged)
  return merged
}

module.exports = buildConfigWithEnginesAndLegacyPlugins
