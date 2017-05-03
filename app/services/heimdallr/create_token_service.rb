module Heimdallr
  class CreateTokenService

    def initialize(application:, scopes:, subject: nil, audience: nil, issuer: nil, not_before: nil, jwt_id: nil, data: {})
      @application = (application.is_a?(String) ? Application.find(application) : application)
      @scopes = case scopes
                  when String then Auth::Scopes.from_string(scopes)
                  when Array  then Auth::Scopes.from_array(scopes)
                  when Auth::Scopes then scopes
                  else
                    raise ArgumentError, 'Must provide scopes argument as either a string or an array.'
                end

      @not_before = not_before
      @audience   = audience
      @subject    = subject
      @issuer     = issuer
      @jwt_id     = jwt_id
      @data       = data
    end

    def call
      app_scopes = Auth::Scopes.from_array(@application.scopes)
      invalid_scopes = app_scopes ^ @scopes
      raise StandardError, "This application is unable to issue tokens with the following scope(s): #{invalid_scopes.join(', ')}" unless invalid_scopes.empty?

      token = Auth::Token.new(@data)
      token.application = @application
      token.not_before  = @not_before
      token.audience    = @audience
      token.subject     = @subject
      token.issuer      = @issuer || @application.name
      token.scopes      = @scopes
      token.jwt_id      = @jwt_id
      token
    end
  end
end
