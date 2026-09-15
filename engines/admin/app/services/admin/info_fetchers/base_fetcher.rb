module Admin
  module InfoFetchers
    class BaseFetcher
      private

      def extract_tags(info, key, category)
        (info.fetch(key)&.split(',') || []).map do |tag|
          tag = tag.strip
          next if tag.blank?

          Tag.find_or_create_by_name(tag, category)
        end.compact
      end
    end
  end
end
