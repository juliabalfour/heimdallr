module Heimdallr
  class DeleteExpiredTokens
    def initialize(older_than: 10.minutes.ago)
      @older_than = older_than
    end

    def call
      Token.where('expires_at <= ?', @older_than.utc).delete_all
    end
  end
end
