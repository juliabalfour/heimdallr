module Heimdallr
  class Application < ActiveRecord::Base
    attr_encrypted_options.merge!(encode: false, encode_iv: false, encode_salt: false)
    attr_encrypted :secret,      key: Heimdallr.secret_key
    attr_encrypted :certificate, key: Heimdallr.secret_key

    attribute :secret
    attribute :certificate

    validates :name, :scopes, :secret, presence: true

    # Generates a secret value using SHA-256.
    def self.generate_secret
      Digest::SHA256.hexdigest(SecureRandom.uuid).to_s
    end

    # Generates a secret value using SHA-256 and updates this record.
    def generate_secret!
      self.secret = generate_secret
    end

    def scopes=(value)
      value = value.split if value.is_a?(String)
      value = value.uniq  if value.is_a?(Array)
      value = value.all   if value.is_a?(Auth::Scopes)
      super(value)
    end

    # Getter for returning the secret or a OpenSSL certificate (depending on the algorithm provided)
    #
    # @param [String] algorithm
    # @return [String, OpenSSL::PKey]
    def secret_or_certificate(algorithm)
      if %w[HS256 HS384 HS512].include?(algorithm)
        secret
      elsif %w[RS256 RS384 RS512].include?(algorithm)
        OpenSSL::PKey::RSA.new(certificate)
      elsif %w[ES256 ES384 ES512].include?(algorithm)
        # TODO: ECDSA encryption does not work at this time
        raise ArgumentError, 'ECDSA encryption does not work at this time'
      end
    end
  end
end
