require 'jwt'
require 'openssl'

module Heimdallr
  module Auth
    class TokenError < StandardError
      attr_accessor :title, :status, :links
      def initialize(title:, detail:, status: 403, links: {})
        @title  = title
        @status = status
        @links  = links
        super(detail)
      end
    end

    # JWT class for creating new & decoding existing tokens.
    #
    # @attr [Hash] data The token data payload.
    # @attr [String] subject Optional subject (SUB) claim.
    # @attr [String] audience Optional audience (AUD) claim.
    # @attr [Integer] not_before Optional not-before (NBF) claim.
    # @attr [String] jwt_id Optional JWT ID (JTI) claim.
    # @attr [String] issuer Optional issuer (ISS) claim.
    # @attr [Integer] expiration_time Optional expiration time (EXP) claim. If this is not provided, then `Heimdallr.expiration_time.from_now.to_i` will be used instead.
    # @attr_reader [Hash] additional_claims Additional claims to include.
    # @attr_reader [Heimdallr::Application] application The application associated with this token.
    class Token
      attr_accessor :data, :subject, :audience, :not_before, :jwt_id, :issuer, :expiration_time
      attr_reader :additional_claims, :application

      CLAIM_EXPIRATION_TIME = 'exp'.freeze
      CLAIM_NOT_BEFORE  = 'nbf'.freeze
      CLAIM_ISSUED_AT   = 'iat'.freeze
      CLAIM_AUDIENCE    = 'aud'.freeze
      CLAIM_SUBJECT     = 'sub'.freeze
      CLAIM_ISSUER      = 'iss'.freeze
      CLAIM_JWT_ID      = 'jti'.freeze
      CLAIM_APP_ID      = 'app'.freeze

      # Attempts to decode a JWT from a string.
      # Note: If the token is successfully decoded, it will be frozen when returned.
      #
      # @param [String] token_string
      # @return [Token]
      def self.from_string(token_string)
        algorithm = Heimdallr.jwt_algorithm.upcase

        begin
          options = {
            verify_iat: true,
            algorithm: algorithm,
            exp_leeway: Heimdallr.expiration_leeway,
            nbf_leeway: Heimdallr.expiration_leeway
          }

          token = new

          # Try to decode the provided string
          payload, = JWT.decode(token_string, nil, true, options) do |header|
            app = Heimdallr::Application.find(header.fetch(CLAIM_APP_ID))
            token.application = app

            # Get the super top secret magical value!
            app.secret_or_certificate(header.fetch('alg'))
          end

          # Store all the claims & return a lightly chilled token!
          token.expiration_time = payload.fetch(CLAIM_EXPIRATION_TIME, nil)
          token.audience = payload.fetch(CLAIM_AUDIENCE, nil)
          token.subject  = payload.fetch(CLAIM_SUBJECT, nil)
          token.jwt_id   = payload.fetch(CLAIM_JWT_ID, nil)
          token.issuer   = payload.fetch(CLAIM_ISSUER, nil)
          token.scopes   = payload.fetch('scopes')
          token.data     = payload.fetch('data')
          return token.freeze

        rescue JWT::VerificationError
          raise TokenError.new(title: 'Invalid Token', detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.')
        rescue JWT::ExpiredSignature
          raise TokenError.new(title: 'Expired Token', detail: 'The provided JWT is expired. Please acquire a new token and try your request again.', links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.4' })
        rescue JWT::IncorrectAlgorithm
          raise TokenError.new(title: 'Incorrect Algorithm', detail: 'The provided JWT was signed with an incorrect algorithm. Please acquire a new token and try your request again.')
        rescue JWT::ImmatureSignature
          raise TokenError.new(title: 'Invalid NBF Claim', detail: 'The provided JWT is not valid yet and cannot be used.', links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.5' })
        rescue JWT::InvalidIssuerError
          raise TokenError.new(title: 'Invalid ISS Claim', detail: 'The provided JWT has an unexpected issuer value. Please acquire a new token and try your request again.', links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.1' })
        rescue JWT::InvalidIatError
          raise TokenError.new(title: 'Invalid IAT Claim', detail: 'The provided JWT is expired or has a malformed header. Please acquire a new token and try your request again.', links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.6' })
        rescue JWT::InvalidSubError
          raise TokenError.new(title: 'Invalid SUB Claim', detail: 'The provided JWT is expired or has a malformed header. Please acquire a new token and try your request again.', links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.2' })
        rescue JWT::InvalidJtiError
          raise TokenError.new(title: 'Invalid JTI Claim', detail: 'The provided JWT is expired or has a malformed header. Please acquire a new token and try your request again.', links: { about: 'https://tools.ietf.org/html/rfc7519#section-4.1.7' })
        rescue JWT::DecodeError => err
          raise TokenError.new(title: 'Invalid Token', detail: err.message, status: 400)
        rescue JWT::InvalidPayload => err
          raise TokenError.new(title: 'Invalid Token', detail: err.message, status: 400)
        end
      end

      # This is my constructor, there are many others like it, but this one is mine.
      #
      # @param [Hash] data
      def initialize(data = {})
        @additional_claims = {}
        @data = data
      end

      # Application setter method.
      #
      # @param [Heimdallr::Application] app
      def application=(app)
        raise ArgumentError, "Expected argument to be `Heimdallr::Application`; received #{app.class}" unless app.is_a?(Heimdallr::Application)
        @application = app
        self
      end

      def scopes
        @scopes ||= Scopes.new
      end

      def scopes=(value)
        @scopes = case value
                    when String then Scopes.from_string(value)
                    when Array  then Scopes.from_array(value)
                    when Scopes then value
                    else
                      raise ArgumentError, 'Must provide a string or array'
                  end
        self
      end

      def add_scope(value)
        scopes.add(value)
        self
      end

      # Adds an additional claim to this token.
      #
      # @param [String, Symbol] claim The name.
      # @param [Object] value The value.
      def add_claim(claim:, value:)
        claim = claim.to_s.downcase.to_sym
        @additional_claims[claim] = value
        self
      end

      # Encodes this token into a JWT string.
      # Adds IAT, EXP, ISS claims automatically.
      #
      # @return [String]
      def encode
        raise StandardError, 'You must set the application object before encoding.' unless @application.is_a?(Heimdallr::Application)

        payload = {
          scopes: scopes.all,
          data: data,
          iat:  Time.now.to_i,
          exp:  expiration_time || Heimdallr.expiration_time.from_now.to_i,
          iss:  issuer,
          sub:  subject,
          aud:  audience,
          nbf:  not_before,
          jti:  jwt_id
        }.merge!(@additional_claims)
        payload.delete_if { |_, value| value.nil? }

        algorithm = Heimdallr.jwt_algorithm.upcase
        secret    = @application.secret_or_certificate(algorithm)

        # Make it so number one!
        JWT.encode(payload, secret, algorithm, CLAIM_APP_ID => application.id)
      end
    end
  end
end
