require 'graphql'

DummySchema = GraphQL::Schema.define do
  query(Types::QueryType)
  mutation(Types::MutationType)

  rescue_from(ActiveRecord::RecordInvalid) do |error|
    'Some data could not be saved'
  end

  rescue_from(ActiveRecord::RecordNotFound) do |error|
    'Could not find the record'
  end

  rescue_from(ActiveRecord::RecordNotUnique) do |error|
    'Some data could not be saved'
  end

  rescue_from(ActiveRecord::Rollback) do |error|
    '--TBD--'
  end

  rescue_from(StandardError) do |error|
    error.message
  end

  resolve_type ->(obj, _) do
    type_name = obj.class.name
    DummySchema.types[type_name]
  end
end
