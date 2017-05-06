module Heimdallr
  module Mutations
    module Tokens
      CreateToken = GraphQL::Relay::Mutation.define do
        # noinspection RubyArgCount
        name 'CreateToken'

        input_field :applicationId, !Heimdallr::Types::UuidType
        input_field :audience,  types.String
        input_field :subject,   types.String
        input_field :scopes,    !types[types.String]

        return_field :token, Heimdallr::Types::TokenType

        resolve ->(obj, args, ctx) {
          token = Heimdallr::CreateTokenService.new(
            application: args[:applicationId],
            scopes: args[:scopes],
            subject: args[:subject],
            audience: args[:audience],
            expires_at: 30.minutes.from_now
          ).call

          { token: token }
        }
      end
    end
  end
end
