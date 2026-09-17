# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    module Goodreads
      # User page for a Goodreads work, e.g. https://www.goodreads.com/work/editions/87596585
      class Work < Base
        BASE_URL = 'https://www.goodreads.com'

        private

        def build_url(id)
          "#{BASE_URL}/work/editions/#{id}"
        end

        # Accepts "87596585", "/work/editions/87596585", or slug forms like "87596585-title".
        def normalized_id
          value = strip_url_noise(identificator)
          return if value.blank?

          value = value.delete_prefix('www.goodreads.com').delete_prefix('goodreads.com')
          value[%r{(?:/work/editions/)?(\d+)}i, 1]
        end
      end
    end
  end
end
