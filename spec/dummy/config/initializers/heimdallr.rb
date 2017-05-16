Heimdallr.configure do |config|

  # The default JWT algorithm to use
  config.default_algorithm = 'HS512'

  # Token validation period (Default: 30 minutes)
  config.expiration_time = -> { 30.minutes.from_now.utc }

  # The JWT expiration leeway
  config.expiration_leeway = 30.seconds

  # The master encryption key
  config.secret_key = 'b72f2be8be4f806e2c9f61171f8a4fedba747341c3aca5f2ef7795af702f4ade'

  # The default scopes to include for requests without a token (Optional)
  config.default_scopes = %w[view create]
end
