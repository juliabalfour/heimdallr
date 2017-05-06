module Heimdallr
  class MissingConfiguration < StandardError
    def initialize
      super 'Configuration for Heimdallr missing. Please create `config/initializers/heimdallr.rb`'
    end
  end

  # @return [Heimdallr::Config]
  def self.configuration
    @config || (raise MissingConfiguration)
  end

  # @yieldparam [Heimdallr::Config] config
  def self.configure
    @config = Config.new
    yield @config
  end

  class Config

    # Gets / Sets the default JWT algorithm to use.
    #
    # @param [String] value
    attr_accessor :default_algorithm

    # Gets / Sets the JWT expiration time to use.
    #
    # @param [Proc] value
    attr_accessor :expiration_time

    # Gets / Sets the JWT expiration leeway.
    #
    # @param [Integer] value
    attr_accessor :expiration_leeway

    # Gets / Sets the master encryption key.
    #
    # @param [String] value
    attr_accessor :secret_key

    # Gets / Sets the default token scopes to use if no token is present.
    #
    # @param [Array]
    attr_accessor :default_scopes

    def initialize
      @default_algorithm  = 'RS256'
      @expiration_time    = -> { 30.minutes.from_now.utc }
      @expiration_leeway  = 30.seconds
    end
  end
end
