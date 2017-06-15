module Heimdallr

  # It does per-attribute encryption for both the secret & certificate fields.
  #
  # @attr [String] secret Used for cryptographically signing JWT tokens when the algorithm is HMAC.
  # @attr [String] name The application name.
  # @attr [String] algorithm The algorithm to use for cryptographically signing JWT tokens.
  #   Must be one of (`HS256`, `HS384`, `HS512`, `RS256`, `RS384`, `RS512`)
  # @attr [Array<String>] scopes The scopes that the application is authorized to issue.
  # @attr [String] key A unique string used when creating new tokens.
  # @attr [String] ip Token issue requests must come from this IP address, or they will be refused (Optional)
  module ApplicationMixin
    extend ActiveSupport::Concern

    included do
      attr_encrypted_options.merge!(encode: false, encode_iv: false, encode_salt: false)
      attr_encrypted :secret,      key: Heimdallr.configuration.secret_key
      attr_encrypted :certificate, key: Heimdallr.configuration.secret_key

      attribute :certificate
      attribute :secret

      before_validation :generate_key, :generate_secret, on: :create
      before_save :check_scopes, :clear_cache

      validates :scopes, :key, :secret, presence: true
    end

    # Set the scopes for this application.
    #
    # @param [String, Array, Auth::Scopes] value The scopes to set.
    def scopes=(value)
      value = value.split if value.is_a?(String)
      value = value.uniq  if value.is_a?(Array)
      value = value.all   if value.is_a?(Auth::Scopes)
      self[:scopes] = value
    end

    # Regenerates the secret key.
    #
    # **Warning:**
    # Calling this method will effectively revoke all tokens owned by this application!
    def regenerate_secret!
      self.secret = excessively_random_string
      save!
    end

    # Regenerates the RSA private key.
    #
    # **Warning:**
    # Calling this method will effectively revoke all tokens owned by this application!
    #
    # @raise [StandardError] If this application does not use RSA for cryptographic signing.
    def regenerate_certificate!
      raise StandardError, 'This application does not use RSA for cryptographic signing' unless %w[RS256 RS384 RS512].include?(algorithm)
      self.certificate = OpenSSL::PKey::RSA.generate(2048).to_s
      save!
    end

    # Gets the RSA certificate for this application.
    #
    # @return [OpenSSL::PKey::RSA]
    def rsa
      raise StandardError, 'This application does not use RSA for cryptographic signing' unless %w[RS256 RS384 RS512].include?(algorithm)
      OpenSSL::PKey::RSA.new(certificate)
    end

    # Getter for returning the secret or a OpenSSL certificate.
    #
    # @return [String, OpenSSL::PKey]
    def secret_or_certificate
      if %w[RS256 RS384 RS512].include?(algorithm)
        return OpenSSL::PKey::RSA.new(certificate)
      end

      secret
    end

    private

    # Generates a new application key if one does not already exist.
    def generate_key
      self.key = excessively_random_string if key.blank?
    end

    # Generates a secret value and if necessary also a RSA certificate.
    def generate_secret
      self.certificate = OpenSSL::PKey::RSA.generate(2048).to_s if %w[RS256 RS384 RS512].include?(algorithm)
      self.secret = excessively_random_string
    end

    # Bordering on pointlessly excessive random string generator.
    #
    # @return [String]
    def excessively_random_string
      Digest::SHA256.hexdigest([
        SecureRandom.uuid,
        SecureRandom.uuid,
        rand(9000)
      ].join).to_s
    end

    # Checks the application scopes and removes duplicates.
    def check_scopes
      scopes = Auth::Scopes.from_array([*self.scopes])
      self.scopes = scopes.all
    end

    # Clears any cached values for this application.
    def clear_cache
      Heimdallr.cache.delete(Application.cache_key(id: id, key: key))
    end
  end
end
