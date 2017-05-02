module Heimdallr
  module Auth
    class Middleware

      BEARER_TOKEN_REGEX = %r{
        ^Bearer\s(
        [a-zA-Z0-9\-_]+\.
        [a-zA-Z0-9\-_]+\.
        [a-zA-Z0-9\-_]*
        )$
      }x

      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        if path_matches_excluded_path?(env)
          @app.call(env)
        elsif missing_auth_header?(env)
          return_error('Missing request header.', source: { header: 'Authorization' })
        elsif invalid_auth_header?(env)
          return_error('Invalid request header format.', source: { header: 'Authorization' })
        else
          verify_token(env)
        end
      end

      private

      def verify_token(env)
        raw_token = BEARER_TOKEN_REGEX.match(env['HTTP_AUTHORIZATION'])[1]

        @app.call(env)
      end

      def path_matches_excluded_path?(env)
        Heimdallr.exclude_paths.any? { |ex| env['PATH_INFO'].start_with?(ex) }
      end

      def valid_auth_header?(env)
        env['HTTP_AUTHORIZATION'] =~ BEARER_TOKEN_REGEX
      end

      def invalid_auth_header?(env)
        !valid_auth_header?(env)
      end

      def missing_auth_header?(env)
        env['HTTP_AUTHORIZATION'].nil? || env['HTTP_AUTHORIZATION'].strip.empty?
      end

      def return_error(message, source: {}, status: 401)
        body = { errors: [{ detail: message, status: status.to_s, source: source }] }.to_json
        headers = { 'Content-Type' => 'application/json', 'Content-Length' => body.bytesize.to_s }
        [status, headers, [body]]
      end
    end
  end
end
