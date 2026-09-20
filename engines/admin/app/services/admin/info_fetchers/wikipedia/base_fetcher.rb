module Admin
  module InfoFetchers
    module Wikipedia
      class BaseFetcher
        private

        def request_data(...)
          url = build_url(...)
          Bench.log("wiki call #{url}") do
            response = Faraday.get(url)
            break JSON.parse(response.body) if response.success?

            Rails.logger.error("Failed GET #{url}: #{response.status}")
            nil
          end
        end

        protected

        def build_url(...)
          raise NotImplementedError
        end
      end
    end
  end
end
