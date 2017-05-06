Heimdallr.configure do |config|
  config.default_algorithm = 'RS256'

  # Token validation period (Default: 30 minutes)
  config.expiration_time = -> { 30.minutes.from_now.utc }

  config.secret_key = 'b0d7a77ce282d506598b5d0cf54b0b36f49389eb9fed174a2d285aad032f30bf'
end
