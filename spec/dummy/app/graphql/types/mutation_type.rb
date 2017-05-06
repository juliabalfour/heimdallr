module Types
  MutationType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Mutation'

    field :createApplication, field: Heimdallr::Mutations::Applications::CreateApplication.field
  end
end
