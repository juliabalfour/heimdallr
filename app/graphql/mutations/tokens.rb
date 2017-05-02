module Mutations
  module Tokens
    CreateToken = GraphQL::Relay::Mutation.define do
      # noinspection RubyArgCount
      name 'CreateToken'

      input_field :grantType, Types::GrantTypeEnum
      input_field :key,       Types::UuidType
      input_field :secret,    types.String
      input_field :scopes,    !types[types.String]

      return_field :jwt, Types::TokenType

      resolve ->(obj, args, ctx) {
        address = ::Address.new

        { address: address }
      }
    end
  end
end
