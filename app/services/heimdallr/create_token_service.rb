require 'jwt'

module Heimdallr
  class CreateTokenService

    # Constructor
    #
    # @param [Application, String] application Either the application object or it's ID.
    # @param [Array] scopes The scopes that this token can access.
    # @param [DateTime] expires_at When this token expires.
    # @param [DateTime] not_before Optional datetime that the token will become active on.
    # @param [String] subject Optional token subject.
    # @param [String] audience
    # @param [Hash] data Optional data to attach to this token.
    # @param [Hash] additional_claims Additional claims to include with the token.
    def initialize(application:, scopes:, expires_at:, not_before: nil, subject: nil, audience: nil, data: {}, additional_claims: {})
      @application = (application.is_a?(String) ? Application.find(application) : application)
      @scopes = case scopes
                  when String then Auth::Scopes.from_string(scopes)
                  when Array  then Auth::Scopes.from_array(scopes)
                  when Auth::Scopes then scopes
                  else
                    raise ArgumentError, 'Must provide scopes argument as either a string or an array.'
                end

      @additional_claims = additional_claims
      @expires_at = expires_at
      @not_before = not_before
      @audience   = audience
      @subject    = subject
      @data       = data
    end

    # @return[String]
    def call
      app_scopes = Auth::Scopes.from_array(@application.scopes)
      invalid_scopes = app_scopes ^ @scopes
      raise StandardError, "This application is unable to issue tokens with the following scope(s): #{invalid_scopes.join(', ')}" unless invalid_scopes.empty?

      token = Token.create(
        application: @application,
        expires_at: @expires_at,
        not_before: @not_before,
        scopes: @scopes.all,
        data: @data
      )

      payload = {
        iat: token.created_at.to_i,
        exp: token.expires_at.to_i,
        nbf: @not_before.to_i,
        iss: @application.id,
        aud: @audience,
        jti: token.id,
        sub: @subject
      }.merge!(@additional_claims)
      payload.delete_if { |_, value| value.nil? }

      algorithm = @application.algorithm
      secret    = @application.secret_or_certificate
      JWT.encode(payload, secret, algorithm)
    end
  end
end
