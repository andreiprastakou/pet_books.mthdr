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


      def fetched_identifiers
        data = fetched_data
        return [] unless data.is_a?(Hash)

        identifiers = data['identifiers'] || data[:identifiers] || {}
        return [] unless identifiers.is_a?(Hash)

        identifiers.flat_map do |resource, values|
          next [] unless Admin::ExternalIdentity.external_resources.key?(resource.to_s)

          Array(values).compact_blank.map { |external_id| [resource.to_s, external_id.to_s] }
        end
      end

      def fetched_description
        data = fetched_data
        return if data.blank? || !data.is_a?(Hash)

        description = data['description'] || data[:description]
        text = case description
               when Hash
                 (description['value'] || description[:value]).presence
               else
                 description.presence
               end
        return if text.blank?

        Rails::Html::FullSanitizer.new.sanitize(text.to_s).presence
      end

      def add_identity!(external_resource, external_id)
        resource = external_resource.to_s
        raise ArgumentError, 'Invalid external resource' unless Admin::ExternalIdentity.external_resources.key?(resource)

        id = external_id.to_s.strip
        raise ArgumentError, 'External ID is required' if id.blank?

        identity = book.external_identities.create!(external_resource: resource, external_id: id)
        Admin::ExternalIdentityIntroductor.call(identity)
      end


      def apply_summary!(summary, summary_src = nil)
        text = summary.to_s.strip
        raise ArgumentError, 'Summary is required' if text.blank?

        attrs = { summary: text }
        attrs[:summary_src] = summary_src.to_s.strip if summary_src.present?
        book.update!(attrs)
      end

      def fetched_data_normalized
        data = fetched_data
        return {} unless data.is_a?(Hash)

        {
          'title' => data['title'],
          'description' => data['description'],
          'authors' => fetched_author_entries(data['authors']),
          'genres' => fetched_id_entries(data['genres']),
          'series' => fetched_series_entries(data['series']),
          'identifiers' => data['identifiers'],
          'links' => fetched_link_urls(data['links']),
          'first_sentence' => fetched_text_value(data['first_sentence']),
          'subject_people' => fetched_string_list(data['subject_people']),
          'covers' => data['covers']
        }.compact_blank
      end

      private

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

      def fetched_link_urls(links)
        return [] unless links.is_a?(Array)

        links.filter_map do |link|
          next unless link.is_a?(Hash)

          link['url'].presence
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
