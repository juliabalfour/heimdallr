module Heimdallr
  module TokenMixin
    extend ActiveSupport::Concern

    included do
      after_find :verify_token_claims
      before_save :check_scopes, :clear_cache

      attribute :token_errors, :string, array: true
      attribute :audience, :string
      attribute :subject,  :string

      delegate :algorithm, :secret, :certificate, to: :application, prefix: true
    end

    class_methods do

      # Finder method used to find a token by the `jti` & `iss` claims.
      #
      # @param [String] id The token ID.
      # @param [String] application_id The application ID.
      def by_id_and_application(id:, application_id:)
        find_by(id: id.to_s, application_id: application_id.to_s)
      end

      # Creates a string that can be used as a cache key.
      #
      # @param [String] id The token ID.
      # @param [String] application The application ID.
      # @return [String]
      def cache_key(id:, application:)
        [application.to_s, id.to_s].join(':')
      end
    end

    # Set the scopes for this token.
    #
    # @param [String, Array, Auth::Scopes] value The scopes to set.
    def scopes=(value)
      value = value.split if value.is_a?(String)
      value = value.uniq  if value.is_a?(Array)
      value = value.all   if value.is_a?(Auth::Scopes)
      self[:scopes] = value
    end

    # Checks whether or not this token has specific scopes.
    #
    # @param [Array] values The scopes to check for.
    def has_scopes?(*values)
      values.all? { |scope| scopes.include?(scope) }
    end

    # Removes one or more scopes.
    #
    # @param [Array] values The scope values to remove.
    def remove_scopes(*values)
      values.each do |scope|
        scopes.delete(scope)
      end
    end

    # Checks whether or not this token has errors.
    #
    # @return [Boolean]
    def token_errors?
      token_errors.present?
    end

    # Encodes this token record into a JWT string.
    #
    # @return [String]
    def encode
      raise StandardError, 'Token must be persisted to the database before encoded.' unless persisted? && !changed?

      payload = {
        iat: created_at.to_i,
        exp: expires_at.to_i,
        nbf: not_before.to_i,
        iss: application.id,
        aud: audience,
        sub: subject,
        jti: id
      }
      payload.delete_if { |_, value| value.nil? }

      algorithm = application.algorithm
      secret    = application.secret_or_certificate
      JWT.encode(payload, secret, algorithm)
    end

    # Verifies that the token loaded from the database is valid and ready to be used.
    def verify_token_claims
      leeway = Heimdallr.configuration.expiration_leeway

      self.token_errors = []
      token_errors << 'This token has been revoked. Please acquire a new token and try your request again.' if revoked?
      token_errors << 'The provided JWT is not valid yet and cannot be used.' if not_before.present? && not_before.to_i > (Time.now.utc.to_i - leeway)
      token_errors << 'The provided JWT is expired. Please acquire a new token and try your request again.' if expires_at.to_i <= (Time.now.utc.to_i - leeway)
    end

    # Checks to ensure that the application can issue a token with the requested scopes.
    def check_scopes
      app_scopes     = Auth::Scopes.from_array([*application.scopes])
      token_scopes   = Auth::Scopes.from_array([*scopes])
      invalid_scopes = app_scopes ^ token_scopes

      # Flip out if we have an unauthorized scope
      raise TokenError.new(title: 'Unable to issue token', detail: "The application that owns this token unable to use following scope(s): #{invalid_scopes&.join(', ')}") unless invalid_scopes.empty?

      self.scopes = token_scopes.all
    end

    # Clears any cached token data & resets errors.
    def clear_cache
      self.token_errors = []
      Heimdallr.cache.delete(Token.cache_key(id: id, application: application_id))
    end
  end
end
