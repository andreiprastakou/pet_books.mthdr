const path = require('path')
const { defineConfig } = require('vitest/config')

const frontendJs = path.resolve(__dirname, 'engines/frontend/app/javascript')
const sharedJs = path.resolve(__dirname, 'app/assets/javascripts')

// Match Shakapacker additional_paths: bare imports like `store/...`, `utils/...`.
const frontendAliases = Object.fromEntries(
  ['components', 'hooks', 'modals', 'pages', 'panels', 'store', 'test', 'utils'].map(name => [
    name,
    path.join(frontendJs, name),
  ])
)
frontendAliases['utils/coverPalettes'] = path.join(sharedJs, 'coverPalettes.js')

module.exports = defineConfig({
  resolve: {
    alias: frontendAliases,
  },
  test: {
    name: 'frontend',
    environment: 'jsdom',
    setupFiles: ['engines/frontend/app/javascript/test/setup.js'],
    include: [
      'engines/frontend/**/*.{test,spec}.{js,jsx}',
      'app/assets/javascripts/**/*.{test,spec}.{js,jsx}',
    ],
    clearMocks: true,
  },
})
