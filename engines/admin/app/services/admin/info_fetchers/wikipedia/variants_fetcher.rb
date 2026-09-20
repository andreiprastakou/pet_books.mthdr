module Admin
  module InfoFetchers
    module Wikipedia
      class VariantsFetcher < ::Admin::InfoFetchers::Wikipedia::BaseFetcher
        PREFERRED_LANGUAGES = %w[en].freeze

        def fetch_variants(page_name, locale)
          variants = { locale => page_name }
          contents = request_data(page_name, locale)
          return variants if contents.blank?

          extract_links_from_response(contents).each do |langlink|
            language = langlink.fetch('lang')
            next unless language.in?(PREFERRED_LANGUAGES)

            variants[language] = langlink.fetch('*')
          end

          variants
        end

        private

        def build_url(page_name, locale)
          "https://#{locale}.wikipedia.org/w/api.php?action=query&titles=#{URI.encode_uri_component(page_name)}&" \
            'prop=langlinks&format=json&lllimit=500'
        end

        def extract_links_from_response(contents)
          links = contents.dig('query', 'pages').values.last['langlinks']
          if links.blank?
            Rails.logger.error("No langlinks found for #{page_name} in #{locale}")
            Rails.logger.debug(contents)
            []
          end
          links
        end
      end
    end
  end
end
