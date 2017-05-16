module Heimdallr
  class CreateApplication

    # Constructor
    #
    # @param [String] name The name.
    # @param [String, Array] scopes The scopes that this application can issue tokens for.
    # @param [String] secret It's a secret to everybody.
    # @param [String] algorithm The algorithm to use.
    # @param [String] ip The ip address this application is restricted to.
    def initialize(name:, scopes:, secret: nil, algorithm: Heimdallr.configuration.default_algorithm, ip: nil)
      @algorithm = algorithm
      @secret = secret
      @scopes = scopes
      @name   = name
      @ip     = ip
    end

    # @return [Application]
    def call
      Application.create!(ip: @ip, name: @name, secret: @secret, scopes: @scopes, algorithm: @algorithm)
    end
  end
end
