module Heimdallr
  class CreateApplicationService

    # Constructor
    #
    # @param [String] name The name.
    # @param [String, Array] scopes The scopes that this application can issue tokens for.
    # @param [String] algorithm The algorithm to use.
    # @param [String] ip The ip address this application is restricted to.
    def initialize(name:, scopes:, algorithm: Heimdallr.jwt_algorithm, ip: nil)
      @algorithm = algorithm
      @name = name
      @ip   = ip

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
      data = {
        ip: @ip,
        name: @name,
        scopes: @scopes.all,
        algorithm: @algorithm,
        secret: Application.generate_secret
      }
      data[:certificate] = OpenSSL::PKey::RSA.generate(2048).to_s if %w[RS256 RS384 RS512].include?(@algorithm)
      Application.create!(data)
    end
  end
end
