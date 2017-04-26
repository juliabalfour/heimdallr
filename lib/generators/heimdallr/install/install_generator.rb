module Heimdallr
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer_file
      template 'initializer.rb.erb', 'config/initializers/heimdallr.rb'
    end
  end
end
