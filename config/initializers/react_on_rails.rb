# frozen_string_literal: true

# React on Rails configuration
# See https://reactonrails.com/docs/configuration/
# for complete documentation of all configuration options.

ReactOnRails.configure do |config|
  # SSR is intentionally disabled in this app.
  # Keep react_on_rails in client-rendered mode unless prerendering is reintroduced.
  config.server_bundle_js_file = ''

  ################################################################################
  # Test Configuration (Recommended)
  ################################################################################
  # ⚠️ IMPORTANT: Two mutually exclusive approaches - use ONLY ONE:
  #
  # RECOMMENDED APPROACH: Use ReactOnRails::TestHelper with build_test_command
  # - Compiles test assets before first render (reliable for SSR and client tests)
  # - Compiles at most once per test run
  # - Works with RSpec and Minitest
  #
  # ALTERNATIVE APPROACH: Set `compile: true` in config/shakapacker.yml test section
  # - Simpler setup, but less explicit control
  # - Can be slower due to on-demand recompilation
  # - See: https://reactonrails.com/docs/building-features/testing-configuration/
  #
  # RSpec apps should also add to spec/rails_helper.rb (inside RSpec.configure):
  #   ReactOnRails::TestHelper.configure_rspec_to_compile_assets(config)
  #
  config.build_test_command = 'RAILS_ENV=test bin/shakapacker'

  # Engine React apps register components in the `frontend` Shakapacker pack, not via
  # react_on_rails file-based packs under app/javascript/packs/generated/.
  config.auto_load_bundle = false
  ################################################################################
  # Advanced Configuration
  ################################################################################
  # Most configuration options have sensible defaults and don't need to be set.
  # For advanced options including:
  # - File-based component registry (components_subdirectory, auto_load_bundle)
  # - Component loading strategies (async/defer/sync)
  # - Server bundle security and organization
  # - I18n configuration
  # - Server rendering pool configuration
  # - Custom rendering extensions
  # - And more...
  #
  # See: https://reactonrails.com/docs/configuration/
end
