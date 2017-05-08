module Heimdallr
  class MutationsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates/mutations', __FILE__)

    desc 'Copies GraphQL mutations into your application.'
    def copy_types
      FileUtils.mkdir_p 'app/graphql/mutations'

      copy_file 'applications.rb', 'app/graphql/mutations/applications.rb'
      copy_file 'tokens.rb', 'app/graphql/mutations/tokens.rb'
    end
  end
end
