module Heimdallr
  class CreateApplicationService

    # Constructor
    #
    # @param [String] name The name.
    # @param [String, Array] scopes The scopes that this application can issue tokens for.
    # @param [String] secret The super secret value.
    # @param [String] ip The ip address this application is restricted to.
    # @param [Boolean] rsa Whether or not RSA encryption should be used.
    def initialize(name:, scopes:, secret: Application.generate_secret, ip: nil, rsa: false)
      @secret = secret
      @name   = name
      @rsa    = rsa
      @ip     = ip

      @scopes = case scopes
                  when String then Auth::Scopes.from_string(scopes)
                  when Array  then Auth::Scopes.from_array(scopes)
                  when Auth::Scopes then scopes
                  else
                    raise ArgumentError, 'Must provide scopes argument as either a string or an array.'
                end
    end

    # @return [Application]
    def call
      certificate = (@rsa ? OpenSSL::PKey::RSA.generate(2048).to_s : nil)
      Application.create!(name: @name, scopes: @scopes.all, secret: @secret, ip: @ip, certificate: certificate)
    end
  end
end
