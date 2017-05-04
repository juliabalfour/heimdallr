require 'heimdallr/engine'

module Heimdallr
  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'heimdallr')
  autoload :Authenticable, File.join(LIBRARY_PATH, 'authenticable')

  module Auth
    AUTH_PATH = File.join(LIBRARY_PATH, 'auth')

    autoload :Token,  File.join(AUTH_PATH, 'token')
    autoload :Scopes, File.join(AUTH_PATH, 'scopes')
  end

  # Configuration/initializer attributes and default values
  class << self
    mattr_accessor :jwt_algorithm, :expiration_time, :expiration_leeway, :secret_key, :issuer, :cache_prefix

    self.jwt_algorithm      = 'RS256'
    self.expiration_time    = 2.hours
    self.expiration_leeway  = 30.seconds
    self.secret_key         = Digest::SHA256.hexdigest(SecureRandom.uuid).to_s
    self.cache_prefix       = 'heimdallr'

    def cache_backend=(backend)
      @cache = backend
    end

    # @return [CacheProxy]
    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new
    end
  end

  def self.setup
    yield self
  end
end
