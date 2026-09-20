# frozen_string_literal: true

module Admin
  module Tasks
    module UrlHost
      extend ActiveSupport::Concern

      class_methods do
        def host_from_url(url)
          URI.parse(url.to_s.strip).host.presence
        rescue URI::InvalidURIError
          nil
        end
      end
    end
  end
end
