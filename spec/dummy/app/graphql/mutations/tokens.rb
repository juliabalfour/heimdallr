module Mutations
  module Tokens
    ApplicationInputType = GraphQL::InputObjectType.define do
      # noinspection RubyArgCount
      name 'ApplicationInput'

      argument :id, !Types::UuidType
      argument :secret, !types.String
    end

    CreateToken = GraphQL::Relay::Mutation.define do
      # noinspection RubyArgCount
      name 'CreateToken'

      input_field :application, !ApplicationInputType
      input_field :audience,  types.String
      input_field :subject,   types.String
      input_field :scopes,    !types[types.String]

      return_field :token, Types::TokenType

      resolve ->(_, args, _) do
        #begin
        token = Heimdallr::CreateToken.new(
          application: args[:application].to_h,
          scopes: args[:scopes],
          subject: args[:subject],
          audience: args[:audience],
          expires_at: Heimdallr.configuration.expiration_time.call
        ).call

        { token: token }
        # rescue ArgumentError, Heimdallr::TokenError => error
        #   GraphQL::ExecutionError.new(error.message)
        # end
      end
    end
  end
end
