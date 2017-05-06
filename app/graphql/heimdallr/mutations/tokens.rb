module Heimdallr
  module Mutations
    module Tokens
      CreateToken = GraphQL::Relay::Mutation.define do
        # noinspection RubyArgCount
        name 'CreateToken'

        input_field :applicationId, !Types::UuidType
        input_field :audience,  types.String
        input_field :subject,   types.String
        input_field :scopes,    !types[types.String]

        return_field :jwt, Types::TokenType

        resolve ->(obj, args, ctx) {
          token = Heimdallr::CreateTokenService.new(
            application: args[:applicationId],
            scopes: args[:scopes]
          ).call

          { jwt: token }
        }
      end
    end
  end
end
