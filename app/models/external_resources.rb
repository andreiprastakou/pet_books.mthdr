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

  # Display labels for frontend_api link buttons.
  LABELS = {
    FAN => 'Fan',
    GOODREADS => 'Goodreads',
    LIBRARYTHING => 'LibraryThing',
    OFFICIAL => 'Official',
    OPEN_LIBRARY => 'Open Library',
    WIKIDATA => 'Wikidata',
    WIKIPEDIA => 'Wikipedia'
  }.freeze

  def self.label_for(external_resource)
    LABELS[external_resource] || external_resource
  end
end
