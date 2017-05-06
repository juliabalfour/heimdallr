require 'heimdallr/engine'
require 'heimdallr/config'

module Heimdallr
  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'heimdallr')
  autoload :Authenticable, File.join(LIBRARY_PATH, 'authenticable')

  module Auth
    AUTH_PATH = File.join(LIBRARY_PATH, 'auth')

    autoload :Token,  File.join(AUTH_PATH, 'token')
    autoload :Scopes, File.join(AUTH_PATH, 'scopes')
  end

  # Autoload all of the service classes
  SERVICES_PATH = File.join(LIBRARY_PATH, 'services')
  autoload :CreateApplication,    File.join(SERVICES_PATH, 'create_application')
  autoload :CreateToken,          File.join(SERVICES_PATH, 'create_token')
  autoload :DecodeToken,          File.join(SERVICES_PATH, 'decode_token')
  autoload :DeleteExpiredTokens,  File.join(SERVICES_PATH, 'delete_expired_tokens')
  autoload :RevokeToken,          File.join(SERVICES_PATH, 'revoke_token')

  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end
end
