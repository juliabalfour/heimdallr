require 'jwt'
require 'openssl'

module Heimdallr
  class DecodeToken

    # Constructor
    #
    # @param [String] jwt The JWT string to decode.
    # @param [Integer] leeway The leeway value to use for expiration & not-before claim verification.
    def initialize(jwt, leeway: 30.seconds)
      @leeway = leeway
      @jwt    = jwt
    end

    # Attempts to decode the JWT string, will raise exceptions with errors.
    #
    # @return [NilClass, Token] Returns nil if no JWT was provided, otherwise returns a Token object.
    def call
      return nil if @jwt.blank?

      decoder = JWT::Decode.new(@jwt, nil, true, {})
      header, payload, signature, signing_input = decoder.decode_segments

      # Grab the issuer & token ID so we can check for blacklisted tokens
      issuer = payload.fetch('iss')
      jwt_id = payload.fetch('jti')

      db_token = Heimdallr.cache.fetch(Token.cache_key(id: jwt_id, application: issuer)) do
        Token.by_ids!(id: jwt_id, application_id: issuer)
      end

      # Grab the algorithm & secret values to use for verification
      algorithm = db_token.application_algorithm
      secret    = db_token.application.secret_or_certificate

      # Verify the JWT signature to help ensure the token has not been tampered with
      JWT.decode_verify_signature(secret, header, signature, signing_input, algorithm: algorithm)
      raise TokenError.new(title: 'Invalid Token', detail: 'Not enough or too many segments.') unless header && payload

      # Ensure that the expiration claim matches what we have stored in the database
      expiration_claim = payload.fetch('exp')
      if expiration_claim.to_i != db_token.expires_at.to_i

        # We want to be semi-vague here since the token was tampered with and we do not know who the guilty party is
        raise TokenError.new(title: 'Invalid Token', detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.')
      end

      # Ensure that the not_before claim matches what we have stored in the database
      not_before_claim = payload.fetch('nbf', nil)
      if not_before_claim.to_i != db_token.not_before.to_i

        # We want to be semi-vague here since the token was tampered with and we do not know who the guilty party is
        raise TokenError.new(title: 'Invalid Token', detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.')
      end

      db_token.audience = payload.fetch('aud', nil)
      db_token.subject  = payload.fetch('sub', nil)
      db_token

    rescue KeyError, ActiveRecord::RecordNotFound
      raise TokenError.new(title: 'Invalid Token', detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.')
    end
  end
end
