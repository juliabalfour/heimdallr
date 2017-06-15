require 'attr_encrypted'
require 'jwt'

require 'active_support/concern'
require 'active_support/cache'

module Heimdallr

  # Implements a Rails engine.
  class Engine < ::Rails::Engine
    config.eager_load_paths += Dir['#{config.root}/lib/**/']
    isolate_namespace Heimdallr

    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
