module Admin
  module InfoFetchers
    module LibraryThing
      module Api
        # Resolves a title to the most likely LibraryThing work (link + related ISBNs).
        # Docs: https://www.librarything.com/developer/documentation/thingapis (thingTitle)
        # Endpoint: GET /api/{token}/thingTitle/{title}
        class WorkByTitleFetcher < BaseCaller
          def initialize(title)
            @title = title
          end

          def fetch
            query = title.to_s.strip
            return if query.blank?

            request_data("thingTitle/#{ERB::Util.url_encode(query)}")
          end

          private

          attr_reader :title
        end
      end
    end
  end
end
