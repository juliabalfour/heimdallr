module Heimdallr
  module Authenticable

    BEARER_TOKEN_REGEX = /^Bearer\s([a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]*)$/

    def heimdallr_authorize!
      heimdallr_token
    rescue Heimdallr::TokenError => error
      heimdallr_render_error(error)
    end

    def heimdallr_token
      @token ||= authenticate_request
    end

    private

    def heimdallr_render_error(error)
      render json: { errors: [error] }, status: error.status
    end

    def authenticate_request
      header = request.authorization
      return create_default_token if invalid_auth_header?(header)

      # Extract the token from the header
      token = BEARER_TOKEN_REGEX.match(header)[1]
      DecodeToken.new(token).call
    end

    def invalid_auth_header?(header)
      header !~ BEARER_TOKEN_REGEX
    end

    def create_default_token
      return nil if Heimdallr.configuration.default_scopes.blank?
      Token.new(scopes: Heimdallr.configuration.default_scopes).freeze
    end
  end
end
