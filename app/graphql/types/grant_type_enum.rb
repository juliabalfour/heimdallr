module Types
  GrantTypeEnum = GraphQL::EnumType.define do
    # noinspection RubyArgCount
    name 'GrantType'

    value('SECRET', 'Application secret grant type.', value: :secret)
  end
end
