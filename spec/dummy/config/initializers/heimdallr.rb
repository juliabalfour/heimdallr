Heimdallr.configure do |config|

  # The default JWT algorithm to use
  config.default_algorithm = 'HS512'

  # Token validation period (Default: 30 minutes)
  config.expiration_time = -> { 30.minutes.from_now.utc }

  # The JWT expiration leeway
  config.expiration_leeway = 30.seconds

  # The master encryption key
  config.secret_key = '07e849a65101e44b4de3bf9306ac3eae836e1093ed53d28b333478ce4543edfa'

  # The default scopes to include for requests without a token (Optional)
  config.default_scopes = %w[view]
end
