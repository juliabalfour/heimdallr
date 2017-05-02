module Types
  ApplicationType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Application'
    description 'JWT Application'

    field :name,    types.String
    field :key,     Types::UuidType
    field :ip,      types.String
    field :secret,  types.String
    field :scopes,  types[types.String]
  end
end
