require 'jwt'

module Heimdallr
  class Token < ActiveRecord::Base
    belongs_to :application

    before_save :purge_cache

    attribute :audience, :string
    attribute :subject, :string

    delegate :algorithm, :secret, :certificate, to: :application, prefix: true

    def self.by_ids!(id:, application:)
      where(id: id, application_id: application).take!
    end

    def self.cache_key(id:, application:)
      [application, id].join(':')
    end

    def revoke!
      self.revoked_at = Time.now.utc
      save!
    end

    def revoke
      self.revoked_at = Time.now.utc
    end

    def revoked?
      !revoked_at.nil?
    end

    def encode
      raise StandardError, 'Token must be persisted to the database before encoded.' unless persisted?

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

    private

    def purge_cache
      Heimdallr.cache.delete(Token.cache_key(id: id, application: application_id))
    end
  end
end
