module Heimdallr
  class RevokeToken

    # Constructor
    #
    # @param [String] id The token ID to revoke.
    def initialize(id:)
      @id = id
    end

    def call
      token = Token.find(@id)
      token.revoke!
    end
  end
end
