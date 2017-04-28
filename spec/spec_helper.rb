$LOAD_PATH.unshift File.dirname(__FILE__)

ENV['RAILS_ENV'] ||= 'test'

require 'capybara/rspec'
require 'dummy/config/environment'
require 'rspec/rails'
require 'generator_spec/test_case'
require 'database_cleaner'
require 'awesome_print'

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  config.infer_base_class_for_anonymous_controllers = false

  config.include RSpec::Rails::RequestExampleGroup, type: :request

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = 'random'
end

require 'heimdallr'
