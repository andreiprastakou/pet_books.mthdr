# frozen_string_literal: true

module ExternalLinks
  # User page for a LibraryThing work, e.g. https://www.librarything.com/work/33363109
  class LibraryThing < Base
    BASE_URL = 'https://www.librarything.com'

    # Accepts "33363109", "/work/33363109", or full URL-ish paths.
    def self.normalize_id(identificator)
      value = identificator.to_s.strip
      return if value.blank?

      value = value.delete_prefix('https://').delete_prefix('http://')
      value = value.split('?', 2).first.to_s.split('#', 2).first.presence
      return if value.blank?

      value = value.delete_prefix('www.librarything.com').delete_prefix('librarything.com')
      value[%r{(?:/work/)?(\d+)\z}i, 1]
    end

    private

    def build_url(id)
      "#{BASE_URL}/work/#{id}"
    end

    def normalized_id
      self.class.normalize_id(identificator)
    end
  end
end
