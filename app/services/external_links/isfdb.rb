# frozen_string_literal: true

module ExternalLinks
  # User page for an ISFDB title, e.g. https://www.isfdb.org/cgi-bin/title.cgi?3537436
  class Isfdb < Base
    BASE_URL = 'https://www.isfdb.org'

    private

    def build_url(id)
      "#{BASE_URL}/cgi-bin/title.cgi?#{id}"
    end

    # Accepts "3537436" or a full title.cgi URL / query string.
    def normalized_id
      value = identificator.to_s.strip
      return if value.blank?

      if value.match?(%r{\Ahttps?://}i) || value.include?('title.cgi')
        query = value.split('?', 2).last
        return query[/(\d+)/, 1] if query
      end

      value[%r{\A(\d+)\z}, 1]
    end
  end
end
