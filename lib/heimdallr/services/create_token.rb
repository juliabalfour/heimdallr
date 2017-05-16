module Heimdallr
  class CreateToken

    # Constructor
    #
    # @param [Application, Hash] application Either an application object or a hash containing an `:id` & `:key` key.
    # @param [Array] scopes The scopes that this token can access.
    # @param [DateTime] expires_at When this token expires.
    # @param [DateTime] not_before Optional datetime that the token will become active on.
    # @param [String] subject Optional token subject.
    # @param [String] audience
    # @param [Hash] data Optional data to attach to this token.
    def initialize(application:, scopes:, expires_at: nil, not_before: nil, subject: nil, audience: nil, data: {})
      if application.is_a?(Hash)
        raise ArgumentError, 'application input must contain `:id` & `:key` symbol keys.' unless application.key?(:id) && application.key?(:key)

        key = application[:key]
        id  = application[:id]

        # Try to find the application & verify the provided key
        @application = Heimdallr.cache.fetch(Application.cache_key(id: id, key: key)) do
          Application.by_id_and_key!(id: id, key: key)
        end
      else
        @application = application
      end

      @expires_at = expires_at&.utc
      @not_before = not_before&.utc
      @audience   = audience
      @subject    = subject
      @scopes     = scopes
      @data       = data
    end

    # @param [Boolean] encode Whether or not the returned token should be encoded.
    # @return [String, Token] Returned a JWT string when the encode argument is true, Token object otherwise.
    def call(encode: true)
      # ip_address = request.remote_ip
      # if @application.ip.present?

      # end

      token = Token.create(
        application: @application,
        expires_at: @expires_at || Heimdallr.configuration.expiration_time.call,
        not_before: @not_before,
        audience: @audience,
        subject: @subject,
        scopes: @scopes,
        # ip: ip_address,
        data: @data
      )

      # Encode the token if requested, otherwise return the object
      encode ? token.encode : token
    end
  end
end
