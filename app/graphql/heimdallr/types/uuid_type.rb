module Heimdallr
  module Types
    UuidType = GraphQL::ScalarType.define do
      # noinspection RubyArgCount
      name 'Uuid'

      coerce_input ->(value, _ctx) { value =~ /[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/ ? value : nil }
      coerce_result ->(value, _ctx) { value.to_s }
      default_scalar true
    end
  end
end
