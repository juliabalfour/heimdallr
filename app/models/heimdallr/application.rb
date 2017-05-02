module Heimdallr
  class Application < ActiveRecord::Base
    attr_encrypted_options.merge!(encode: false, encode_iv: false, encode_salt: false)
    attr_encrypted :secret,      key: Heimdallr.secret_key
    attr_encrypted :certificate, key: Heimdallr.secret_key

    attribute :secret
    attribute :certificate

    #
    # @return [Auth::Scopes]
    def scopes
      Auth::Scopes.from_string(self[:scopes])
    end

    #
    # @return [String]
    def scopes_string
      self[:scopes]
    end

    # Checks whether or not this application has specific scopes.
    #
    # @param [Array] required_scopes The scopes to check for.
    # @return [Boolean]
    def includes_scope?(*required_scopes)
      required_scopes.blank? || required_scopes.any? { |scope| scopes.exists?(scope.to_s) }
    end

    # Getter for returning the secret or a OpenSSL certificate (depending on the algorithm provided)
    #
    # @param [String] algorithm
    # @return [String, OpenSSL::PKey]
    def secret_or_certificate(algorithm)
      if %w[HS256 HS384 HS512].include?(algorithm)
        secret
      elsif %w[RS256 RS384 RS512].include?(algorithm)
        OpenSSL::PKey::RSA.new(certificate).public_key
      elsif %w[ES256 ES384 ES512].include?(algorithm)
        ecdsa_key     = OpenSSL::PKey::EC.new(certificate)
        ecdsa_public  = OpenSSL::PKey::EC.new(ecdsa_key)
        ecdsa_public.private_key = nil
        ecdsa_public
      end
    end
  end
end
