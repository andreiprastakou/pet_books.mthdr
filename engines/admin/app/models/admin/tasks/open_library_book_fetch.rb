# == Schema Information
#
# Table name: admin_data_fetch_tasks
# Database name: primary
#
#  id                  :integer          not null, primary key
#  fetch_error_details :string
#  fetched_data        :json
#  input_data          :json
#  status              :string           not null
#  target_type         :string           not null
#  type                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_id             :integer
#  target_id           :integer          not null
#
# Indexes
#
#  index_admin_data_fetch_tasks_on_chat_id  (chat_id)
#  index_admin_data_fetch_tasks_on_target   (target_type,target_id)
#
# Foreign Keys
#
#  chat_id  (chat_id => ai_chats.id)
#
module Admin
  module Tasks
    class OpenLibraryBookFetch < BaseTask
      def self.setup(external_identity)
        create!(target: external_identity)
      end

      alias external_identity target

      def book
        owner = external_identity.owner
        raise ArgumentError, 'Open Library fetch target must belong to a book' unless owner.is_a?(::Book)

        Admin::Book.cast(owner)
      end

      def perform
        result = Admin::InfoFetchers::OpenLibrary::Api::BookDetailsFetcher.new(external_identity.external_id).fetch
        if result
          save_results!(result)
        else
          save_results!(nil, errors: [StandardError.new('Failed to fetch Open Library work data')])
        end
      end

      def add_identity!(external_resource, external_id)
        resource = external_resource.to_s
        raise ArgumentError, 'Invalid external resource' unless Admin::ExternalIdentity.external_resources.key?(resource)

        id = external_id.to_s.strip
        raise ArgumentError, 'External ID is required' if id.blank?

        identity = book.external_identities.create!(external_resource: resource, external_id: id)
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def add_author_identity!(author_key, author:)
        olid = Admin::ExternalLinkBuilders::OpenLibrary::Author.normalize_id(author_key)
        raise ArgumentError, 'Invalid Open Library author key' if olid.blank?
        raise ArgumentError, 'Author is required' if author.blank?
        raise ArgumentError, 'Author is not linked to this book' unless book.authors.exists?(id: author.id)

        identity = Admin::Author.cast(author).external_identities.create!(
          external_resource: ExternalResources::OPEN_LIBRARY,
          external_id: olid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def add_genre_identity!(genre_key, genre:)
        olid = self.class.normalize_open_library_key(genre_key)
        raise ArgumentError, 'Invalid Open Library genre key' if olid.blank?
        raise ArgumentError, 'Genre is required' if genre.blank?
        raise ArgumentError, 'Genre is not linked to this book' unless book.genres.exists?(genre_id: genre.id)

        identity = Admin::Genre.cast(genre).external_identities.create!(
          external_resource: ExternalResources::OPEN_LIBRARY,
          external_id: olid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def add_series_identity!(series_key, series:)
        olid = self.class.normalize_open_library_key(series_key)
        raise ArgumentError, 'Invalid Open Library series key' if olid.blank?
        raise ArgumentError, 'Series is required' if series.blank?
        raise ArgumentError, 'Series is not linked to this book' unless book.series.exists?(id: series.id)

        identity = Admin::Series.cast(series).external_identities.create!(
          external_resource: ExternalResources::OPEN_LIBRARY,
          external_id: olid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def apply_summary!(text)
        summary = text.to_s.strip
        raise ArgumentError, 'Summary is required' if summary.blank?

        book.upsert_description_from_source!(self, text: summary, source_label: nil)
      end

      def add_link!(url, external_resource:)
        resource = external_resource.to_s.strip
        raise ArgumentError, 'External resource is required' if resource.blank?

        link_url = url.to_s.strip
        raise ArgumentError, 'URL is required' if link_url.blank?

        link = book.external_links.find_or_initialize_by(url: link_url)
        link.external_resource = resource
        link.save!
        link
      end

      def fetched_data_normalized
        data = fetched_data
        return {} unless data.is_a?(Hash)

        {
          'title' => data['title'],
          'description' => fetched_description_text(data['description']),
          'authors' => fetched_author_entries(data['authors']),
          'genres' => fetched_id_entries(data['genres']),
          'series' => fetched_series_entries(data['series']),
          'identifiers' => fetched_identifier_entries(data['identifiers']),
          'links' => fetched_link_entries(data['links']),
          'first_sentence' => fetched_text_value(data['first_sentence']),
          'subject_people' => fetched_string_list(data['subject_people']),
          'covers' => data['covers']
        }.compact_blank
      end

      def applyable_links
        Array(fetched_data_normalized['links'])
      end

      def self.normalize_open_library_key(key)
        value = key.to_s.strip
        return if value.blank?

        value = value.delete_prefix('https://openlibrary.org').delete_prefix('http://openlibrary.org')
        value.split('?', 2).first.to_s.split('#', 2).first.presence
      end

      def self.open_library_url(key)
        path = normalize_open_library_key(key)
        return if path.blank?
        return path if path.match?(%r{\Ahttps?://}i)

        "https://openlibrary.org#{path.start_with?('/') ? path : "/#{path}"}"
      end

      def self.host_from_url(url)
        URI.parse(url.to_s.strip).host.presence
      rescue URI::InvalidURIError
        nil
      end

      private

      def fetched_description_text(description)
        text = fetched_text_value(description)
        return if text.blank?

        Rails::Html::FullSanitizer.new.sanitize(text.to_s).presence
      end

      def fetched_identifier_entries(identifiers)
        return [] unless identifiers.is_a?(Hash)

        identifiers.flat_map do |resource, values|
          next [] unless Admin::ExternalIdentity.external_resources.key?(resource.to_s)

          Array(values).compact_blank.map do |external_id|
            { 'external_resource' => resource.to_s, 'external_id' => external_id.to_s }
          end
        end
      end

      def fetched_author_entries(authors)
        return [] unless authors.is_a?(Array)

        authors.filter_map do |author_entry|
          next unless author_entry.is_a?(Hash)

          external_id = author_entry.dig('author', 'key').presence
          { 'external_id' => external_id } if external_id
        end
      end

      def fetched_series_entries(series)
        return [] unless series.is_a?(Array)

        series.filter_map do |series_entry|
          next unless series_entry.is_a?(Hash)

          external_id = series_entry.dig('series', 'key').presence
          { 'external_id' => external_id } if external_id
        end
      end

      def fetched_id_entries(values)
        return [] unless values.is_a?(Array)

        values.filter_map do |external_id|
          id = external_id.presence
          { 'external_id' => id } if id
        end
      end

      def fetched_link_entries(links)
        return [] unless links.is_a?(Array)

        links.filter_map do |link|
          next unless link.is_a?(Hash)

          url = link['url'].presence
          next unless url

          host = self.class.host_from_url(url)
          next if host.blank?

          { 'external_resource' => host, 'url' => url }
        end
      end

      def fetched_text_value(value)
        case value
        when Hash
          value['value'].presence
        else
          value.presence
        end
      end

      def fetched_string_list(values)
        return [] unless values.is_a?(Array)

        values.filter_map { |value| value.presence&.to_s }
      end
    end
  end
end
