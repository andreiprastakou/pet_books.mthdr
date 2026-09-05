# frozen_string_literal: true

require 'capybara/cuprite'

Capybara.default_max_wait_time = 10
Capybara.server = :puma, { Silent: true }
Capybara.server_host = '127.0.0.1'
Capybara.disable_animation = true

module CupriteHelpers
  def basic_auth_as_admin!
    page.driver.browser.network.authorize(
      user: ENV.fetch('ADMIN_USERNAME'),
      password: ENV.fetch('ADMIN_PASSWORD')
    ) do |request|
      request.continue
    end
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :system

  config.before(:each, type: :system) do
    # Capybara boots a local server; Ferrum talks to Chromium over CDP on localhost.
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.prepend_before(:each, type: :system) do
    driven_by :cuprite, screen_size: [1400, 1000], options: {
      js_errors: true,
      headless: !ENV['HEADLESS'].in?(%w[n 0 no false]),
      process_timeout: 20,
      timeout: 15,
      inspector: ENV['INSPECTOR'],
      browser_options: {
        'no-sandbox': nil,
        'disable-gpu': nil,
        'disable-dev-shm-usage': nil
      },
      browser_path: ENV.fetch('BROWSER_PATH', nil)
    }.compact
  end
end
