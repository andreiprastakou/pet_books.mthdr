module InfoFetchers
  module Wiki
    class UrlParser
      def self.extract_base_name_and_locale(url)
        locale = url.match(%r{^https?://([\w-]*)\.wikipedia\.org/})&.[](1)
        name = url[%r{wiki/(.*)$}, 1]
        name = CGI.unescape(name) if name.present?
        [name, locale]
      end
    end
  end
end
