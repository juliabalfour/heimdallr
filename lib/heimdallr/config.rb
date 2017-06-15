module Heimdallr

  # Error class that is raised when the application did not create a Heimdallr initializer.
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

  # Heimdallr configuration class.
  #
  # @attr [String] default_algorithm The default JWT algorithm to use.
  # @attr [Proc] expiration_time The JWT expiration time to use.
  # @attr [Integer] expiration_leeway The JWT expiration leeway.
  # @attr [String] secret_key The master encryption key.
  # @attr [Array<String>] default_scopes The default token scopes to use if no token is present.
  class Config
    attr_accessor :application_model, :token_model, :default_algorithm, :expiration_time, :expiration_leeway, :secret_key, :default_scopes

    # Constructor, sets default config values.
    def initialize
      @default_algorithm  = 'RS256'
      @expiration_time    = -> { 30.minutes.from_now.utc }
      @expiration_leeway  = 30.seconds
    end
  end
end
