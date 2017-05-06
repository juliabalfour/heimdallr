module Heimdallr
  module Mutations
    module Applications
      CreateApplication = GraphQL::Relay::Mutation.define do
        # noinspection RubyArgCount
        name 'CreateApplication'

        input_field :name,      !types.String
        input_field :scopes,    !types[types.String]
        input_field :algorithm, !Heimdallr::Types::AlgorithmTypeEnum

        return_field :application, Heimdallr::Types::ApplicationType

        resolve ->(obj, args, ctx) {
          application = Heimdallr::CreateApplicationService.new(
            name: args[:name],
            scopes: args[:scopes],
            algorithm: args[:algorithm]
          ).call

          { application: application }
        }
      end
    end
  end
end
