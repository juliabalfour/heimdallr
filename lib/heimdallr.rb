require 'heimdallr/engine'

module Heimdallr
  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'heimdallr')

  module Auth
    AUTH_PATH = File.join(LIBRARY_PATH, 'auth')

    autoload :Scopes, File.join(AUTH_PATH, 'scopes')
    autoload :Token,  File.join(AUTH_PATH, 'token')
  end

  # Configuration/initializer attributes and default values
  class << self
    mattr_accessor :jwt_algorithm, :issuer, :expiration_time, :expiration_leeway, :secret_key, :private_key_path, :default_scopes, :declare_crud_scopes

    self.jwt_algorithm        = 'HS256'
    self.issuer               = 'TODO: Token Issuer'
    self.expiration_time      = 2.hours
    self.expiration_leeway    = 20.seconds
    self.secret_key           = Digest::SHA256.hexdigest(SecureRandom.uuid).to_s
    self.private_key_path     = nil
    self.default_scopes       = 'users:view'
    self.declare_crud_scopes  = 'users'
  end

  def self.setup
    yield self
  end
end
