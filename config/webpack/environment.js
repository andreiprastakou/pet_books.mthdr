const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Add rule for .mjs files
environment.loaders.append('mjs', {
  test: /\.mjs$/,
  include: /node_modules/,
  type: 'javascript/auto'
})

// Add resolve configuration
environment.config.merge({
  resolve: {
    extensions: ['.mjs', '.js', '.jsx', '.json']
  }
})

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

const nodeModulesLoader = environment.loaders.get('nodeModules');
if (!Array.isArray(nodeModulesLoader.exclude)) {
  nodeModulesLoader.exclude = nodeModulesLoader.exclude == null ? [] : [nodeModulesLoader.exclude];
}

nodeModulesLoader.exclude.push(/react-table/);

// Add engine entry points
const path = require('path')
const engineEntries = {
  // Admin engine entry point
  admin: path.resolve(__dirname, '../../engines/admin/app/javascript/packs/admin.js'),
  // Frontend engine entry point (named 'frontend' to avoid conflict with main app's application.js)
  frontend: path.resolve(__dirname, '../../engines/frontend/app/javascript/packs/application.js')
}

// Merge engine entry points with existing entries
environment.config.entry = Object.assign({}, environment.config.entry || {}, engineEntries)

module.exports = environment
