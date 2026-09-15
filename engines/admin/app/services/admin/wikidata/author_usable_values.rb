# frozen_string_literal: true

module Admin
  module Wikidata
    # Usable values for person / author Wikidata items.
    # Property meanings: https://www.wikidata.org/wiki/Property:P569 (etc.)
    # People modelling: https://www.wikidata.org/wiki/Wikidata:WikiProject_Biography
    # Writers (within books): https://www.wikidata.org/wiki/Wikidata:WikiProject_Books
    class AuthorUsableValues < BaseUsableValues
      # multi: true  -> array of extracted values
      # multi: false -> first extracted value (or nil)
      STATEMENT_FIELDS = {
        'P569' => { key: 'date_of_birth', multi: false },
        'P570' => { key: 'date_of_death', multi: false },
        'P648' => { key: 'open_library_id', multi: false },
        'P2963' => { key: 'goodreads_id', multi: false },
        'P7400' => { key: 'librarything_id', multi: false },
        'P31' => { key: 'instance_of', multi: true },
        'P27' => { key: 'countries', multi: true },
        'P19' => { key: 'place_of_birth', multi: true },
        'P106' => { key: 'occupations', multi: true },
        'P136' => { key: 'genres', multi: true },
        'P166' => { key: 'awards', multi: true },
        'P1412' => { key: 'languages', multi: true },
        'P18' => { key: 'image', multi: false }
      }.freeze
    end
  end
end
