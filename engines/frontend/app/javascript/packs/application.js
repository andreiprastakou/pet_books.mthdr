// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from '@rails/ujs'
import 'jquery'
import 'lodash'

Rails.start()

// Initialize React components
const componentRequireContext = require.context('components', true)
const ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)

// Prevent server-side rendering in development
if (process.env.NODE_ENV === 'development')
  window.ReactRailsUJS = ReactRailsUJS

