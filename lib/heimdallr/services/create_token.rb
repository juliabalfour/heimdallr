module Heimdallr
  class CreateToken

    # Constructor
    #
    # @param [Application, String] application Either the application object or it's ID.
    # @param [Array] scopes The scopes that this token can access.
    # @param [DateTime] expires_at When this token expires.
    # @param [DateTime] not_before Optional datetime that the token will become active on.
    # @param [String] subject Optional token subject.
    # @param [String] audience
    # @param [Hash] data Optional data to attach to this token.
    def initialize(application:, scopes:, expires_at:, not_before: nil, subject: nil, audience: nil, data: {})
      @application = (application.is_a?(String) ? Application.find(application) : application)
      @scopes = case scopes
                  when String then Auth::Scopes.from_string(scopes)
                  when Array  then Auth::Scopes.from_array(scopes)
                  when Auth::Scopes then scopes
                  else
                    raise ArgumentError, 'Must provide scopes argument as either a string or an array.'
                end

      @expires_at = expires_at&.utc
      @not_before = not_before&.utc
      @audience   = audience
      @subject    = subject
      @data       = data
    end

    # @param [Boolean] encode Whether or not the returned token should be encoded.
    # @return [String, Token] Returned a JWT string when the encode argument is true, Token object otherwise.
    def call(encode: true)
      app_scopes = Auth::Scopes.from_array(@application.scopes)
      invalid_scopes = app_scopes ^ @scopes
      raise StandardError, "This application is unable to issue tokens with the following scope(s): #{invalid_scopes.join(', ')}" unless invalid_scopes.empty?

      if @application.ip.present?

      end

      token = Token.create(
        application: @application,
        expires_at: @expires_at,
        not_before: @not_before,
        scopes: @scopes.all,
        audience: @audience,
        subject: @subject,
        data: @data
      )

      # Encode the token if requested, otherwise return the object
      encode ? token.encode : token
    end
  end
end
