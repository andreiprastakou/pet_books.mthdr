# frozen_string_literal: true

module Admin
  module InfoFetchers
    # Runs inside Faraday's retry stack so each attempt (including retries) is spaced.
    # Pass Faraday options: name: and min_interval_seconds: (do not close over outer constants).
    class RateLimitMiddleware < Faraday::Middleware
      def initialize(app, options = {})
        super(app)
        @name = options.fetch(:name)
        @min_interval_seconds = options.fetch(:min_interval_seconds)
      end

      def on_request(_env)
        Admin::ExternalApiRateLimit.throttle!(
          @name,
          min_interval_seconds: @min_interval_seconds
        )
      end
    end
  end
end
