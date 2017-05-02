DummySchema = GraphQL::Schema.define do
  query(Types::QueryType)

  resolve_type ->(obj, _) do
    type_name = obj.class.name
    DummySchema.types[type_name]
  end
end
