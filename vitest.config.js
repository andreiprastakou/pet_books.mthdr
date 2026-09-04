const path = require('path')
const { defineConfig } = require('vitest/config')

const frontendJs = path.resolve(__dirname, 'engines/frontend/app/javascript')

// Match Shakapacker additional_paths: bare imports like `store/...`, `utils/...`.
const frontendAliases = Object.fromEntries(
  ['components', 'hooks', 'modals', 'pages', 'panels', 'store', 'test', 'utils'].map(name => [
    name,
    path.join(frontendJs, name),
  ])
)

module.exports = defineConfig({
  resolve: {
    alias: frontendAliases,
  },
  test: {
    name: 'frontend',
    environment: 'jsdom',
    setupFiles: ['engines/frontend/app/javascript/test/setup.js'],
    include: ['engines/frontend/**/*.{test,spec}.{js,jsx}'],
    clearMocks: true,
  },
})
