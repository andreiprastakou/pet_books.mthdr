const clientWebpackConfig = require('./clientWebpackConfig')

// const testOnly = _clientWebpackConfig => {
//   place any code here that is for test only
// }
// testOnly(configForTest)

const configForTest = clientWebpackConfig()

module.exports = configForTest
