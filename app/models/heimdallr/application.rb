module Heimdallr
  class Application < ActiveRecord::Base
    attr_encrypted_options.merge!(encode: false, encode_iv: false, encode_salt: false)
    attr_encrypted :secret,      key: Heimdallr.configuration.secret_key
    attr_encrypted :certificate, key: Heimdallr.configuration.secret_key

    attribute :secret
    attribute :certificate

    before_validation :generate_key, on: :create
    before_validation :generate_secret_or_certificate, on: :create

    before_save :purge_cache

    validates :name, :scopes, :key, :secret, presence: true

    has_many :tokens

    def self.by_id_and_key!(id:, key:)
      where(id: id, key: key).take!
    end

    def self.cache_key(id:, key:)
      [key, id].join(':')
    end

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

    def generate_key
      self.key = excessively_random_string if key.blank?
    end

    def generate_secret_or_certificate
      self.certificate = OpenSSL::PKey::RSA.generate(2048).to_s if %w[RS256 RS384 RS512].include?(algorithm)
      self.secret = excessively_random_string
    end

    def excessively_random_string
      Digest::SHA256.hexdigest([
        SecureRandom.uuid,
        SecureRandom.uuid,
        rand(9000)
      ].join).to_s
    end

    def purge_cache
      Heimdallr.cache.delete(Application.cache_key(id: id, key: key))
    end
  end
end
