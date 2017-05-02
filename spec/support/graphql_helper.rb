module GraphQL
  module Helpers
    def graphql(query:, variables: {})
      body = {}
      body[:query] = query
      body[:variables] = variables if variables.any?

      post('/graphql', JSON.generate(body))
    end
  end
end

RSpec.configure do |config|
  config.include GraphQL::Helpers
end
