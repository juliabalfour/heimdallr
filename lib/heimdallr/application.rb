module Heimdallr
  class Application
    class << self

      # Creates a new application.
      #
      # @example
      #  application = Heimdallr::Application.create(
      #     name: 'My Little Pony',
      #     scopes: %w[rainbow:create unicorn:hug pony:create pony:update pony:ride],
      #     algorithm: 'RS256',
      #     ip: request.remote_ip
      #   )
      #
      # @param [String] name The name.
      # @param [String, Array] scopes The scopes that this application can issue tokens for.
      # @param [String] secret It's a secret to everybody.
      # @param [String] algorithm The algorithm to use.
      # @param [String] ip The ip address this application is restricted to.
      #
      # @return [Application]
      # @raise [ActiveRecord::RecordInvalid]
      def create(name:, scopes:, secret: nil, algorithm: Heimdallr.configuration.default_algorithm, ip: nil)
        application_model  = Heimdallr.configuration.application_model
        application_record = application_model.create!(ip: ip, name: name, secret: secret, scopes: scopes, algorithm: algorithm)
        Application.new(model_class: application_model, record: application_record)
      end

      # Find an application by it's ID and key.
      #
      # @param [String] id The application ID.
      # @param [String] key The application key.
      # @return [Application]
      def by_id_and_key(id:, key:)
        application_model  = Heimdallr.configuration.application_model
        application_record = application_model.find_by(id: id.to_s, key: key.to_s)
        Application.new(model_class: application_model, record: application_record)
      end

      # Creates a string that can be used as a cache key.
      #
      # @param [String] id The token ID.
      # @param [String] key The application key.
      # @return [String]
      def cache_key(id:, key:)
        [key.to_s, id.to_s].join(':')
      end
    end

    attr_reader :model_class, :record

    # Constructor
    #
    # @param [ActiveRecord::Base] model_class
    # @param [Object] record
    def initialize(model_class:, record:)
      @model_class = model_class
      @record      = record
    end
  end
end
