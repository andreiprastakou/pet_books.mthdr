# frozen_string_literal: true

module ExternalResources
  OFFICIAL = 'official'
  FAN = 'fan'
  GOODREADS = 'goodreads'
  LIBRARYTHING = 'librarything'
  OPEN_LIBRARY = 'open_library'
  WIKIDATA = 'wikidata'
  WIKIPEDIA = 'wikipedia'

  ALL = [
    FAN,
    GOODREADS,
    LIBRARYTHING,
    OFFICIAL,
    OPEN_LIBRARY,
    WIKIDATA,
    WIKIPEDIA
  ].freeze

  # Stored for admin tooling; omitted from frontend_api responses.
  INTERNAL = [
    WIKIDATA
  ].freeze
end
