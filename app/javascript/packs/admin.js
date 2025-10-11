import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

// Initialize Stimulus
const application = Application.start()
const context = require.context("../admin/stimulus_controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
