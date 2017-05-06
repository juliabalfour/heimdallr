require 'attr_encrypted'
require 'active_support/cache'

module Heimdallr
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

    initializer :append_migrations do |app|
      # This prevents migrations from being loaded twice from the inside of the gem itself (dummy test app)
      if app.root.to_s !~ /#{root}/
        config.paths['db/migrate'].expanded.each do |migration_path|
          app.config.paths['db/migrate'] << migration_path
        end
      end
    end
  end
end
