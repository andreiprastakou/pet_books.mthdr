# frozen_string_literal: true

module ExternalLinks
  # User page for a LibraryThing work, e.g. https://www.librarything.com/work/33363109
  class LibraryThing < Base
    BASE_URL = 'https://www.librarything.com'

    private

    def build_url(id)
      "#{BASE_URL}/work/#{id}"
    end

    # Accepts "33363109", "/work/33363109", or full URL-ish paths.
    def normalized_id
      value = strip_url_noise(identificator)
      return if value.blank?

      value = value.delete_prefix('www.librarything.com').delete_prefix('librarything.com')
      value[%r{(?:/work/)?(\d+)\z}i, 1]
    end
  end
end
