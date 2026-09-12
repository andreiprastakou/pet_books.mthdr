// Common configuration applying to client and server configuration
const path = require('path')
const { generateWebpackConfig, merge } = require('shakapacker')

const baseClientWebpackConfig = generateWebpackConfig()

const commonOptions = {
  resolve: {
    extensions: ['.css', '.ts', '.tsx'],
    alias: {
      'utils/coverPalettes': path.resolve(__dirname, '../../app/assets/javascripts/coverPalettes.js'),
    },
  },
}

// Copy the object using merge b/c the baseClientWebpackConfig and commonOptions are mutable globals
const commonWebpackConfig = () => merge({}, baseClientWebpackConfig, commonOptions)

module.exports = commonWebpackConfig
