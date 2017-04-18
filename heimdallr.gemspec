$:.push File.expand_path('../lib', __FILE__)

require 'heimdallr/version'

Gem::Specification.new do |s|
  s.name            = 'heimdallr'
  s.version         = Heimdallr::VERSION
  spec.authors      = ['Nate Strandberg']
  spec.email        = ['nate@juliabalfour.com']

  spec.summary      = 'Supercalifragilisticexpialidocious'
  spec.description  = 'Even though the sound of it / Is something quite atrocious!'
  spec.homepage     = 'http://juliabalfour.com'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end
  spec.files = Dir['{app,config,lib}/**/*', 'Rakefile', 'README.md']

  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'railties', '~> 5.1.0.rc1'
  spec.add_dependency 'jwt'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
