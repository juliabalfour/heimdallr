$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "heimdallr/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "heimdallr"
  s.version     = Heimdallr::VERSION
  s.authors     = ["Nick Brabant"]
  s.email       = ["nick@juliabalfour.com"]
  s.homepage    = "https://github.com/juliabalfour/heimdallr"
  s.summary     = "JWT Middleware for Ruby on Rails"
  s.description = "JWT Authorization engine"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.1.0.rc2"
  s.add_dependency "jwt", "~> 1.5.6"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "bump"
end
