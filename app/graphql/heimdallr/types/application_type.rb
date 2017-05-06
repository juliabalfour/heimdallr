module Heimdallr
  module Types
    ApplicationType = GraphQL::ObjectType.define do
      # noinspection RubyArgCount
      name 'Application'
      description 'JWT Application'

      field :id,        UuidType
      field :name,      types.String
      field :ip,        types.String
      field :secret,    types.String
      field :scopes,    types[types.String]
      field :algorithm, AlgorithmTypeEnum
    end
  end
end
