require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require 'heimdallr'

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    Rails.application.config.middleware.insert_before 0, Heimdallr::Auth::Middleware

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
