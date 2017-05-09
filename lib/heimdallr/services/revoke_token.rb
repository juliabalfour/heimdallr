module Heimdallr
  class RevokeToken

    # Constructor
    #
    # @param [String] id Token ID to revoke.
    # @param [String] application_id Application ID.
    def initialize(id:, application_id:)
      @application_id = application_id
      @id = id
    end

    def call
      token = Token.by_ids!(id: @id, application: @application_id)
      token.revoke!
    end
  end
end
