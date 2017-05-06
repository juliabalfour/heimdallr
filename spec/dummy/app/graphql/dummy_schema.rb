require 'graphql'

DummySchema = GraphQL::Schema.define do
  query(Types::QueryType)
  mutation(Types::MutationType)

  resolve_type ->(obj, _) do
    type_name = obj.class.name
    DummySchema.types[type_name]
  end
end
