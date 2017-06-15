module Heimdallr

  # Heimdallr installation generator.
  #
  # **Usage**
  #
  # ```shell
  # rails g heimdallr:install
  # ```
  #
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include Rails::Generators::Migration
    def self.next_migration_number(path)
      next_migration_number = current_migration_number(path) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    desc 'Installs Heimdallr.'
    def copy_initializer_file
      template 'initializer.rb.erb', 'config/initializers/heimdallr.rb'
    end

    def copy_migration_file
      raise StandardError, 'Heimdallr currently only supports PostgreSQL' unless postgresql?

      migration_template 'migrate/create_heimdallr_applications.rb', 'db/migrate/create_heimdallr_applications.rb'
      migration_template 'migrate/create_heimdallr_tokens.rb', 'db/migrate/create_heimdallr_tokens.rb'
    end

    private

    # Checks whether or not the database is PostgreSQL.
    def postgresql?
      config = ActiveRecord::Base.configurations[Rails.env]
      config && config['adapter'] == 'postgresql'
    end

    # Checks whether or not the model file exists.
    #
    # @return [Boolean]
    def model_exists?
      File.exist?(File.join(destination_root, model_path))
    end

    # Checks whether or not a given migration file exists.
    #
    # @param [String] table_name The migration table name to check for.
    # @return [Boolean]
    def migration_exists?(table_name)
      Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_add_heimdallr_#{table_name}.rb$/).first
    end

    # @return [String]
    def migration_path
      @migration_path ||= File.join('db', 'migrate')
    end

    # @return [String]
    def model_path
      @model_path ||= File.join('app', 'models', "#{file_path}.rb")
    end
  end
end
