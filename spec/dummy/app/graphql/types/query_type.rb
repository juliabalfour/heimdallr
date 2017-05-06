module Types
  QueryType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Query'

    field :fabulous, types.String do
      resolve ->(_, _, _) { 'Supercalifragilisticexpialidocious' }
    end

  end
end
