module Heimdallr
  class Application < ActiveRecord::Base
    attr_encrypted_options.merge!(encode: false, encode_iv: false, encode_salt: false)
    attr_encrypted :secret,      key: Heimdallr.configuration.secret_key
    attr_encrypted :certificate, key: Heimdallr.configuration.secret_key

    has_many :tokens

    attribute :secret
    attribute :certificate

    before_validation :generate_key, :generate_secret, on: :create
    before_save :check_scopes, :clear_cache

    validates :name, :scopes, :key, :secret, presence: true

    # Find an application by it's ID and key.
    #
    # @param [String] id The application ID.
    # @param [String] key The application key.
    def self.by_id_and_key!(id:, key:)
      where(id: id, key: key).take!
    end

    def self.cache_key(id:, key:)
      [key, id].join(':')
    end

    # Set the scopes for this application.
    #
    # @param [String, Array, Auth::Scopes] value The scopes to set.
    def scopes=(value)
      value = value.split if value.is_a?(String)
      value = value.uniq  if value.is_a?(Array)
      value = value.all   if value.is_a?(Auth::Scopes)
      super(value)
    end

    # Getter for returning the secret or a OpenSSL certificate.
    #
    # @return [String, OpenSSL::PKey]
    def secret_or_certificate
      if %w[HS256 HS384 HS512].include?(algorithm)
        secret
      elsif %w[RS256 RS384 RS512].include?(algorithm)
        OpenSSL::PKey::RSA.new(certificate)
      elsif %w[ES256 ES384 ES512].include?(algorithm)
        # TODO: ECDSA encryption does not work at this time
        raise ArgumentError, 'ECDSA encryption does not work at this time'
      end
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

    # Bordering on pointlessly random string generator.
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
