module Types
  MutationType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Mutation'

    field :createApplication, field: Heimdallr::Mutations::Applications::CreateApplication.field
    field :createToken, field: Heimdallr::Mutations::Tokens::CreateToken.field
  end
end
