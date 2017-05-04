module Heimdallr
  module Types
    TimeType = GraphQL::ScalarType.define do
      # noinspection RubyArgCount
      name 'Time'

      coerce_input ->(value, _ctx) { Time.at(Float(value)).utc }
      coerce_result ->(value, _ctx) { value.to_f }
      default_scalar true
    end
  end
end
