# frozen_string_literal: true

module ExternalLinks
  # User page for a Wikidata entity, e.g. https://www.wikidata.org/wiki/Q137179018
  class Wikidata < Base
    BASE_URL = 'https://www.wikidata.org'

    private

    def build_url(id)
      "#{BASE_URL}/wiki/#{id}"
    end

    # Accepts "Q137179018", "/wiki/Q137179018", or full URL-ish paths.
    def normalized_id
      value = strip_url_noise(identificator)
      return if value.blank?

      value = value.delete_prefix('www.wikidata.org').delete_prefix('wikidata.org')
      value[%r{(?:/wiki/)?(Q\d+)\z}i, 1]&.upcase
    end
  end
end
