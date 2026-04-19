const clientWebpackConfig = require('./clientWebpackConfig')

const configForProduction = clientWebpackConfig()

// const productionEnvOnly = _clientWebpackConfig => {
//   place any code here that is for production only
// }
// productionEnvOnly(configForProduction)

module.exports = configForProduction
