module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Searches Wikidata items by a Book's title.
        class BookSearcher < EntitySearcher
          def query_text
            query_source.title
          end
        end
      end
    end
  end
end
