module Types
  QueryType = GraphQL::ObjectType.define do
    # noinspection RubyArgCount
    name 'Query'

    field :fabulous, types.String do
      resolve ->(_, _, _) { 'Supercalifragilisticexpialidocious' }
    end

    field :token, types.String do
      resolve ->(_, _, ctx) do
        token = ctx[:token]
        token.inspect
      end
    end
  end
end
