# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

raise('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'database_cleaner/active_record'
require 'webmock/rspec'

require 'simplecov_support' if ENV.fetch('COVERAGE', false)

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

# Load support files from engines
Rails.root.glob('engines/*/spec/support/**/*.rb').each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Include spec files from engines
  config.pattern = 'spec/**/*_spec.rb,engines/*/spec/**/*_spec.rb'

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include AuthHelper, type: :request
  config.include ApiRequestsHelper, type: :request
  config.include Admin::Engine.routes.url_helpers

  # Make engine route helpers available to helper objects in helper specs
  config.before(:each, type: :helper) do
    helper.extend(Admin::Engine.routes.url_helpers)
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
