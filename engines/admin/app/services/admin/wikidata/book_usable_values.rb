# frozen_string_literal: true

module Admin
  module Wikidata
    # Usable values for book (work) Wikidata items.
    # Property meanings: https://www.wikidata.org/wiki/Property:P50 (etc.)
    # Book modelling: https://www.wikidata.org/wiki/Wikidata:WikiProject_Books
    class BookUsableValues < BaseUsableValues
      # multi: true  -> array of extracted values
      # multi: false -> first extracted value (or nil)
      STATEMENT_FIELDS = {
        'P50' => { key: 'authors', multi: true },
        'P648' => { key: 'open_library_id', multi: false },
        'P1085' => { key: 'librarything_id', multi: false },
        'P8383' => { key: 'goodreads_id', multi: false },
        'P2034' => { key: 'gutenberg_id', multi: false },
        'P577' => { key: 'publication_date', multi: false },
        'P31' => { key: 'instance_of', multi: true },
        'P179' => { key: 'series', multi: true },
        'P136' => { key: 'genres', multi: true },
        'P166' => { key: 'awards', multi: true },
        'P495' => { key: 'country_of_origin', multi: true }
      }.freeze
    end
  end
end
