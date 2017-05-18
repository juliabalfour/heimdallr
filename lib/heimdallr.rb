require 'heimdallr/engine'
require 'heimdallr/config'

# Namespace for the Heimdallr gem.
module Heimdallr

  # Error class that is raised when a critical token error occurs.
  class TokenError < StandardError
    attr_accessor :title, :status, :links
    def initialize(title:, detail:, status: 403, links: {})
      @title  = title
      @status = status
      @links  = links
      super(detail)
    end
  end

  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'heimdallr')
  autoload :Authenticable, File.join(LIBRARY_PATH, 'authenticable')

  module Auth
    AUTH_PATH = File.join(LIBRARY_PATH, 'auth')
    autoload :Scopes, File.join(AUTH_PATH, 'scopes')
  end

  # Autoload all of the service classes
  SERVICES_PATH = File.join(LIBRARY_PATH, 'services')
  autoload :CreateApplication,    File.join(SERVICES_PATH, 'create_application')
  autoload :CreateToken,          File.join(SERVICES_PATH, 'create_token')
  autoload :DecodeToken,          File.join(SERVICES_PATH, 'decode_token')
  autoload :DeleteExpiredTokens,  File.join(SERVICES_PATH, 'delete_expired_tokens')
  autoload :RevokeToken,          File.join(SERVICES_PATH, 'revoke_token')

  # @return [ActiveSupport::Cache::Store]
  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end
end
