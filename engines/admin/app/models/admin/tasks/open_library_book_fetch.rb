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
    # rubocop:disable-next Metrics/ClassLength
    class OpenLibraryBookFetch < BaseTask
      include Admin::Tasks::ExternalIdentityFetchable
      include Admin::Tasks::AttachesOpenLibraryAuthorIdentity
      include Admin::Tasks::UrlHost
      include Admin::Tasks::OpenLibraryDetailsFetchable
      include Admin::Tasks::AppliesDescriptionText

      RELATED_IDENTITY_TYPES = {
        genre: {
          cast_class: Admin::Genre,
          linked: ->(book, genre) { book.genres.exists?(genre_id: genre.id) }
        },
        series: {
          cast_class: Admin::Series,
          linked: ->(book, series) { book.series.exists?(id: series.id) }
        }
      }.freeze

      def book
        cast_identity_owner!(
          ::Book,
          Admin::Book,
          'Open Library fetch target must belong to a book'
        )
      end

      RELATED_IDENTITY_TYPES.each do |label, config|
        define_method(:"add_#{label}_identity!") do |key, **kwargs|
          owner = kwargs.fetch(label)
          add_linked_open_library_identity!(
            key,
            owner: owner,
            cast_class: config[:cast_class],
            linked: ->(record) { instance_exec(book, record, &config[:linked]) },
            label: label.to_s
          )
        end
      end

      def apply_summary!(text)
        apply_description_text!(text, owner: book, required_label: 'Summary')
      end

      def fetched_data_normalized
        data = fetched_data
        return {} unless data.is_a?(Hash)

        normalized_book_payload(data)
      end

      def normalized_book_payload(data) # rubocop:disable Metrics/AbcSize
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

      private

      def details_fetcher
        Admin::InfoFetchers::OpenLibrary::Api::BookDetailsFetcher.new(external_identity.external_id)
      end

      def fetch_failure_message
        'Failed to fetch Open Library work data'
      end

      def add_linked_open_library_identity!(key, owner:, cast_class:, linked:, label:)
        olid = self.class.normalize_open_library_key(key)
        raise ArgumentError, "Invalid Open Library #{label} key" if olid.blank?
        raise ArgumentError, "#{label.capitalize} is required" if owner.blank?
        raise ArgumentError, "#{label.capitalize} is not linked to this book" unless linked.call(owner)

        create_introduced_identity!(
          cast_class.cast(owner),
          external_resource: ExternalResources::OPEN_LIBRARY,
          external_id: olid
        )
      end

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
        fetched_nested_key_entries(authors, 'author')
      end

      def fetched_series_entries(series)
        fetched_nested_key_entries(series, 'series')
      end

      def fetched_nested_key_entries(entries, nested_key)
        return [] unless entries.is_a?(Array)

        entries.filter_map do |entry|
          next unless entry.is_a?(Hash)

          external_id = entry.dig(nested_key, 'key').presence
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
