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

    def is_revoked?
      !revoked_at.nil?
    end

    def purge_cache
      Heimdallr.cache.delete(Token.cache_key(id: id, application: application_id))
    end
  end
end
