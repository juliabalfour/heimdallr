module Heimdallr
  module Authenticable

    BEARER_TOKEN_REGEX = /^Bearer\s([a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]*)$/

    def heimdallr_authorize!
      heimdallr_token
    rescue TokenError => error
      heimdallr_render_error(error)
    end

    def heimdallr_token
      @token ||= authenticate_request
    end

    private

    def heimdallr_render_error(error)
      render json: { errors: [error.to_json] }, status: error.status
    end

    def authenticate_request
      header = request.authorization
      return nil if invalid_auth_header?(header)

      # Extract the token from the header
      token = BEARER_TOKEN_REGEX.match(header)[1]
      DecodeTokenService.new(token).call
    end

    def invalid_auth_header?(header)
      header !~ BEARER_TOKEN_REGEX
    end
  end
end
