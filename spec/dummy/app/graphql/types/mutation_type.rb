module Types
  MutationType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Mutation'

    field :createApplication, field: Mutations::Applications::CreateApplication.field
    field :createToken, field: Mutations::Tokens::CreateToken.field
  end
end
