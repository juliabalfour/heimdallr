module Heimdallr
  module Authenticable

    def heimdallr_authorize!
    end

    def heimdallr_authorize
    end

    def heimdallr_token
    end

    private

    def heimdallr_render_errors
      render json: { errors: [] }
    end
  end
end
