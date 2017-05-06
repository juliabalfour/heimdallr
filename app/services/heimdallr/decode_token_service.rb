require 'jwt'
require 'openssl'

module Heimdallr
  class TokenError < StandardError
    attr_accessor :title, :status, :links
    def initialize(title:, detail:, status: 403, links: {})
      @title  = title
      @status = status
      @links  = links
      super(detail)
    end
  end

  class DecodeTokenService

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
    # @param [Boolean] frozen Whether or not the token returned should be immutable.
    # @return [NilClass, Token] Returns nil if no JWT was provided, otherwise returns a Token object.
    def call(frozen: true)
      return nil if @jwt.blank?

      decoder = JWT::Decode.new(@jwt, nil, true, {})
      header, payload, signature, signing_input = decoder.decode_segments

      # Grab the issuer & token ID so we can check for blacklisted tokens
      issuer = payload.fetch('iss')
      jwt_id = payload.fetch('jti')

      db_token = Heimdallr.cache.fetch(Token.cache_key(id: jwt_id, application: issuer)) do
        Token.by_ids!(id: jwt_id, application: issuer)
      end

      # Check if the token was revoked in the database
      raise TokenError.new(title: 'Invalid Token', detail: 'This token has been revoked. Please acquire a new token and try your request again.') if db_token.revoked?

      # Grab the algorithm & secret values to use for verification
      algorithm = db_token.application_algorithm
      secret    = db_token.application.secret_or_certificate

      # Verify the JWT signature to help ensure the token has not been tampered with
      JWT.decode_verify_signature(secret, header, signature, signing_input, algorithm: algorithm)
      raise TokenError.new(title: 'Invalid Token', detail: 'Not enough or too many segments.') unless header && payload

      # Run custom validation on the token to ensure sanity
      verify_expiration_claim(payload.fetch('exp'), db_token)
      verify_not_before_claim(payload.fetch('nbf', nil), db_token)

      db_token.audience = payload.fetch('aud', nil)
      db_token.subject  = payload.fetch('sub', nil)
      frozen ? db_token.freeze : db_token

    rescue KeyError, ActiveRecord::RecordNotFound
      raise TokenError.new(title: 'Invalid Token', detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.')
    end

    private

    # Verifies the EXP claim and raises an exception if something is amiss.
    #
    # @param [String] claim The expiration claim from the decoded token.
    # @param [Token] token The database token that was found using the JWI claim.
    def verify_expiration_claim(claim, token)
      if claim != token.expires_at.to_i

        # We want to be semi-vague here since the token was tampered with and we do not know who the guilty party is
        raise TokenError.new(title: 'Invalid Token', detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.')
      end

      # Check if the token has expired
      if claim.to_i <= (Time.now.utc.to_i - @leeway)
        raise TokenError.new(
          title: 'Expired Token',
          detail: 'The provided JWT is expired. Please acquire a new token and try your request again.',
          links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.4' }
        )
      end
    end

    # Verifies the NBF claim and raises an exception if something is amiss.
    #
    # @param [String] claim The NBF claim from the decoded token.
    # @param [Token] token The database token that was found using the JWI claim.
    def verify_not_before_claim(claim, token)
      return if token.not_before.nil?

      if claim.to_i != token.not_before.to_i

        # We want to be semi-vague here since the token was tampered with and we do not know who the guilty party is
        raise TokenError.new(title: 'Invalid Token', detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.')
      end

      # Check if the token can be used yet
      if claim.to_i > (Time.now.utc.to_i - @leeway)
        raise TokenError.new(
          title: 'Invalid NBF Claim',
          detail: 'The provided JWT is not valid yet and cannot be used.',
          links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.5' }
        )
      end
    end
  end
end
