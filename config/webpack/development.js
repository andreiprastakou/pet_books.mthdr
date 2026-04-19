const { config } = require('shakapacker')
const mergeWebpackerAndShakapacker = require('./merge_webpacker_and_shakapacker')

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

const configForDevelopment = mergeWebpackerAndShakapacker()
developmentEnvOnly(configForDevelopment)

module.exports = configForDevelopment
