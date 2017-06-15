require 'rails/generators/active_record'
require_relative 'model_helpers'

module Heimdallr

  # Heimdallr model generator.
  #
  # **Usage**
  #
  # ```shell
  # rails g heimdallr:application MODEL_NAME
  # ```
  #
  class ApplicationGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates/migrate', __FILE__)

    include Heimdallr::Generators::ModelHelpers

    def copy_migration_file
      raise StandardError, 'Heimdallr currently only supports PostgreSQL' unless postgresql?

      if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
        migration_template 'migration_existing_application.rb.erb', "db/migrate/add_heimdallr_#{table_name}.rb"
      else
        migration_template 'application_migration.rb.erb', "db/migrate/heimdallr_create_#{table_name}.rb"
      end
    end

    def generate_model
      invoke 'active_record:model', [name], migration: false unless model_exists? && behavior == :invoke
    end

    def inject_model_content
      content = <<-CONTENT
      include Heimdallr::ApplicationMixin

      has_many :tokens
      CONTENT

      class_path = if namespaced?
                     class_name.to_s.split('::')
                   else
                     [class_name]
                   end

      indent_depth = class_path.size - 1
      content      = content.split("\n").map { |line| '  ' * indent_depth + line } .join("\n") << "\n"

      inject_into_class(model_path, class_path.last, content) if model_exists?
    end
  end
end
