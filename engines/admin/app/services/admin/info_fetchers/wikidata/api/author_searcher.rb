module Admin
  module InfoFetchers
    module Wikidata
      module Api
        # Searches Wikidata items by an Author's name.
        class AuthorSearcher < EntitySearcher
          def query_text
            query_source.fullname
          end
        end
      end
    end
  end
end
