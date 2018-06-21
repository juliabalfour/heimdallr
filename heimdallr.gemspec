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

  spec.cert_chain  = ['certs/heimdallr.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $0 =~ /gem\z/

  spec.add_dependency 'dry-configurable', '~> 0.7.0'
  spec.add_dependency 'railties', '~> 5.2'
  spec.add_dependency 'jwt', '~> 2.1'

  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'github-markup'

  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'spring'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'pg', '~> 0.20'
  spec.add_development_dependency 'puma', '~> 3.7'
  spec.add_development_dependency 'graphiql-rails'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'rake', '>= 11.3.0'
  spec.add_development_dependency 'rails', '~> 5.2'
  spec.add_development_dependency 'generator_spec', '~> 0.9.3'
  spec.add_development_dependency 'graphql', '>= 1.8.4', '< 2'
  spec.add_development_dependency 'database_cleaner', '~> 1.5.3'
  spec.add_development_dependency 'spring-watcher-listen', '~> 2.0.0'
end
