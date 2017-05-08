begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'

desc 'Default: run specs.'
task default: :spec

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec) do |config|
  config.verbose = false
end

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

load 'rails/tasks/statistics.rake'

namespace :heimdallr do
  desc 'Install Heimdallr into dummy app'
  task :install do
    cd 'spec/dummy'
    system 'bundle exec rails g heimdallr:install --force'
  end

  desc 'Install Heimdallr GraphQL types into dummy app'
  task :types do
    cd 'spec/dummy'
    system 'bundle exec rails g heimdallr:types --force'
  end

  desc 'Install Heimdallr GraphQL mutations into dummy app'
  task :mutations do
    cd 'spec/dummy'
    system 'bundle exec rails g heimdallr:mutations --force'
  end
end

Bundler::GemHelper.install_tasks
