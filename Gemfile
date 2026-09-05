source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.6'

# runners
gem 'bootsnap', '>= 1.4.4', require: false
gem 'puma', '~> 7.2'
gem 'rails', '~> 8.1'

# data storage
gem 'redis'
gem 'sqlite3', '~> 2.9'

# integrations
gem 'foreman'
gem 'httparty'

# background jobs
gem 'mission_control-jobs'
gem 'solid_queue', '~> 1.2.4'

# views
gem 'jbuilder', '~> 2.7'
gem 'kaminari'
gem 'react_on_rails'
gem 'sassc-rails'
gem 'shakapacker', '= 10.0'
# rack-proxy 1.0+ refuses Host-derived backends by default (SSRF hardening),
# which breaks Shakapacker::DevServerProxy (/packs -> 502).
# Pin until https://github.com/shakacode/shakapacker/issues/1220 is fixed.
gem 'rack-proxy', '< 1.0'
gem 'slim'
gem 'turbo-rails', '~> 2.0'

# media storage
gem 'carrierwave'
gem 'carrierwave-base64'
gem 'fog-aws'
# image_processing 2.x made mini_magick a soft dependency; CarrierWave::MiniMagick still needs it
gem 'mini_magick', '~> 5.0'

# self-analysis
gem 'annotaterb', '~> 4.14'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# admin site
gem 'pagy', '~> 43.5'
gem 'ruby_llm', '~> 1.6'

# tools
gem 'benchmark'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 3.1', require: 'dotenv/load'
  gem 'pry-rails'
end

group :development do
  gem 'bundler-audit', require: false
  gem 'listen', '~> 3.3'
  gem 'pronto'
  gem 'pronto-flay', require: false
  gem 'pronto-rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'rugged'
  gem 'spring'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'rspec-rails', '~> 8.0'

  gem 'capybara', '>= 3.26'
  gem 'cuprite'
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 7.0'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end

# Engines
gem 'admin', path: 'engines/admin'
gem 'frontend', path: 'engines/frontend'
gem 'frontend_api', path: 'engines/frontend_api'
