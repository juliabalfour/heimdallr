require 'jwt'
require 'openssl'

module Heimdallr
  module Auth
    class Token
      attr_accessor :data, :error, :subject, :audience, :not_before, :jwt_id, :issuer, :expiration_time
      attr_reader :additional_claims

      # Decodes an existing JWT.
      #
      # @param [String] token_string The token to decode.
      # @param [String] algorithm The algorithm to use for decoding.
      # @return [Token]
      def self.decode(token_string:, algorithm: Heimdallr.jwt_algorithm)
        decoded_token = nil
        error         = nil
        algorithm.upcase!

        begin
          options = {
            verify_iss: true,
            verify_iat: true,
            algorithm: algorithm,
            exp_leeway: Heimdallr.expiration_leeway
          }

          if %w[RS256 RS384 RS512].include?(algorithm)

            # Load the private key file & decode using the public key
            rsa_private = OpenSSL::PKey::RSA.new File.read(Heimdallr.private_key_path)
            decoded_token, = JWT.decode(token_string, rsa_private.public_key, true, options)

          elsif %w[ES256 ES384 ES512].include?(algorithm)

            ecdsa_key     = OpenSSL::PKey::EC.new File.read(Heimdallr.private_key_path)
            ecdsa_public  = OpenSSL::PKey::EC.new ecdsa_key
            ecdsa_public.private_key = nil

            decoded_token, = JWT.decode(token_string, ecdsa_public, true, options)

          elsif %w[HS256 HS384 HS512].include?(algorithm)
            decoded_token, = JWT.decode(token_string, Heimdallr.secret_key, true, options)
          else
            raise ArgumentError, "Unable to decode token, `#{algorithm}` is invalid."
          end
        rescue JWT::VerificationError
          error = {
            title: 'Invalid Token',
            detail: 'The provided JWT is invalid. Please acquire a new token and try your request again.',
            status: 403
          }
        rescue JWT::ExpiredSignature
          error = {
            title: 'Expired Token',
            detail: 'The provided JWT is expired. Please acquire a new token and try your request again.',
            status: 403,
            links: {
              about: 'https://tools.ietf.org/html/rfc7519#section-4.1.4'
            }
          }
        rescue JWT::IncorrectAlgorithm
          error = {
            title: 'Incorrect Algorithm',
            detail: 'The provided JWT was signed with an incorrect algorithm. Please acquire a new token and try your request again.',
            status: 403
          }
        rescue JWT::ImmatureSignature
          error = {
            title: 'Invalid NBF Claim',
            detail: 'The provided JWT is not valid yet and cannot be used.',
            status: 403,
            links: {
              about: 'https://tools.ietf.org/html/rfc7519#section-4.1.5'
            }
          }
        rescue JWT::InvalidIssuerError
          error = {
            title: 'Invalid ISS Claim',
            detail: 'The provided JWT has an unexpected issuer value. Please acquire a new token and try your request again.',
            status: 403,
            links: {
              about: 'https://tools.ietf.org/html/rfc7519#section-4.1.1'
            }
          }
        rescue JWT::InvalidIatError
          error = {
            title: 'Invalid IAT Claim',
            detail: 'The provided JWT is expired or has a malformed header. Please acquire a new token and try your request again.',
            status: 403,
            links: {
              about: 'https://tools.ietf.org/html/rfc7519#section-4.1.6'
            }
          }
        rescue JWT::InvalidSubError
          error = {
            title: 'Invalid SUB Claim',
            detail: 'The provided JWT has an unexpected subject and cannot be used. Please acquire a new token and try your request again.',
            status: 403,
            links: {
              about: 'https://tools.ietf.org/html/rfc7519#section-4.1.2'
            }
          }
        rescue JWT::InvalidJtiError
          error = {
            title: 'Invalid JTI Claim',
            detail: 'The provided JWT has an unexpected identifier and cannot be used. Please acquire a new token and try your request again.',
            status: 422,
            links: {
              about: 'https://tools.ietf.org/html/rfc7519#section-4.1.7'
            }
          }
        rescue JWT::DecodeError => err
          error = {
            title: 'Unexpected Error',
            detail: err.message,
            status: 400
          }
        rescue JWT::InvalidPayload => err
          error = {
            title: 'Unexpected Error',
            detail: err.message,
            status: 400
          }
        end

        token = new
        if decoded_token.is_a?(Hash)
          decoded_token.deep_symbolize_keys!
          token.data      = decoded_token.fetch(:data)
          token.subject   = decoded_token.fetch(:sub) { nil }
          token.issuer    = decoded_token.fetch(:iss) { nil }
          token.audience  = decoded_token.fetch(:aud) { nil }
          token.expiration_time = decoded_token.fetch(:exp)
        else
          token.error = error
        end

        token.freeze
      end

      # Constructor
      #
      # @param [Hash] data Payload data to include.
      def initialize(data = {})
        @additional_claims = {}
        @data = data
      end

      # Whether or not there was an error decoding this token.
      #
      # @return [Boolean]
      def error?
        @error.present?
      end

      # Adds a public claim.
      #
      # @param [String,Symbol] claim The claim to add.
      # @param [Object] value The claim value.
      # @return [self]
      def add_claim(claim:, value:)
        claim.to_s.downcase!.to_sym
        @additional_claims[claim] = value
        self
      end

      # Converts the token instance to a JWT string.
      # Adds IAT, EXP, ISS claims automatically.
      #
      # @return [String]
      def to_s
        payload = {
          data: data,
          iat:  Time.now.to_i,
          exp:  expiration_time || Heimdallr.expiration_time.from_now.to_i,
          iss:  issuer || Heimdallr.issuer,
          sub:  subject,
          aud:  audience,
          nbf:  not_before,
          jti:  jwt_id
        }.merge!(additional_claims)
        payload.delete_if { |_, value| value.nil? }

        algorithm = Heimdallr.jwt_algorithm.upcase
        if %w[RS256 RS384 RS512].include?(algorithm)
          rsa_private = OpenSSL::PKey::RSA.new File.read(Heimdallr.private_key_path)
          issued_token = JWT.encode(payload, rsa_private, algorithm)
        elsif %w[ES256 ES384 ES512].include?(algorithm)
          ecdsa_key = OpenSSL::PKey::EC.new File.read(Heimdallr.private_key_path)
          issued_token = JWT.encode(payload, ecdsa_key, algorithm)
        elsif %w[HS256 HS384 HS512].include?(algorithm)
          issued_token = JWT.encode(payload, Heimdallr.secret_key, algorithm)
        else
          raise ArgumentError, "Unable to issue token, `#{algorithm}` is invalid."
        end

        issued_token
      end
    end
  end
end
