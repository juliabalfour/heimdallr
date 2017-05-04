Heimdallr.setup do |config|
  config.jwt_algorithm = 'HS512'
  config.issuer = 'TODO: Token Issuer'

  # Token validation period (Default: 2 hours)
  config.expiration_time = 2.hours

  config.secret_key = 'b0d7a77ce282d506598b5d0cf54b0b36f49389eb9fed174a2d285aad032f30bf'
end
