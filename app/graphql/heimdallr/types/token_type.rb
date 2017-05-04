module Heimdallr
  module Types
    TokenType = GraphQL::ObjectType.define do
      # noinspection RubyArgCount
      name 'Token'
      description 'JWT Token'

      field :application, Types::ApplicationType do
        resolve ->(token, _, _) { token.application }
      end

      field :jwt, types.String do
        resolve ->(obj, _, _) { obj.token }
      end
    end
  end
end
