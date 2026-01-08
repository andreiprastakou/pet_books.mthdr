require 'simplecov'

COVERAGE_MINIMUM = 97

SimpleCov.start 'rails' do
  coverage_dir 'spec/coverage'

  add_filter 'app/helpers/' # simplecov fails to count their coverage by specs

  add_group 'Services', 'app/services'

  groups.delete 'Channels'
  groups.delete 'Helpers'
  groups.delete 'Mailers'
  groups.delete 'Jobs'
  groups.delete 'Libraries'
end

SimpleCov.minimum_coverage COVERAGE_MINIMUM

Rails.application.eager_load!
