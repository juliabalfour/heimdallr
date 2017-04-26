module Heimdallr
  class Engine < ::Rails::Engine

    # Mount the engine to the root app as middleware
    config.middleware.use Heimdallr::Engine.middleware

    # Configuration/initializer attributes and default values
    class << self
      mattr_accessor :jwt_algorithm,
                     :issuer,
                     :expiration_time,
                     :secret_key,
                     :default_scopes,
                     :declare_crud_scopes

      self.jwt_algorithm = 'HS512'
      self.issuer = 'TODO: Token Issuer'
      self.expiration_time = 2.hours
      self.secret_key = Digest::SHA256.hexdigest(SecureRandom.uuid).to_s
      self.default_scopes = 'users:view'
      self.declare_crud_scopes = 'users'
    end

    def self.setup
      yield self
    end

  end
end
