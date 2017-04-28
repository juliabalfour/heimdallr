$:.push File.expand_path('../lib', __FILE__)

require 'heimdallr/version'

Gem::Specification.new do |spec|
  spec.name        = 'heimdallr'
  spec.version     = Heimdallr::VERSION
  spec.authors     = ['Nick Brabant', 'Nate Strandberg']
  spec.email       = %w[nick@juliabalfour.com nate@juliabalfour.com]
  spec.homepage    = 'https://github.com/juliabalfour/heimdallr'
  spec.summary     = 'JWT Middleware for Ruby on Rails'
  spec.description = 'JWT Authorization engine'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency 'railties', '>= 5.1.0'
  spec.add_dependency 'jwt', '~> 1.5.6'

  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'database_cleaner', '~> 1.5.3'
  spec.add_development_dependency 'factory_girl', '~> 4.7.0'
  spec.add_development_dependency 'generator_spec', '~> 0.9.3'
  spec.add_development_dependency 'rake', '>= 11.3.0'
  spec.add_development_dependency 'rspec-rails'
end
