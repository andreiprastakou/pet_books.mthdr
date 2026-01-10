require_relative 'lib/frontend/version'

Gem::Specification.new do |spec|
  spec.name        = 'frontend'
  spec.version     = Frontend::VERSION
  spec.authors     = ['Andrei Prastakou']
  spec.email       = ['andrew.prostakov@gmail.com']
  spec.homepage    = 'https://github.com/andreiprastakou/pet_books.mthdr'
  spec.summary     = 'Frontend engine for Infospace Books'
  spec.description = 'Frontend engine for Infospace Books'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 8.1'
  spec.required_ruby_version = '>= 3.4'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
