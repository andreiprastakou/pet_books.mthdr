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
    class OpenLibraryAuthorFetch < BaseTask
      def self.setup(external_identity)
        create!(target: external_identity)
      end

      alias external_identity target

      def author
        owner = external_identity.owner
        raise ArgumentError, 'Open Library author fetch target must belong to an author' unless owner.is_a?(::Author)

        Admin::Author.cast(owner)
      end

      def perform
        result = Admin::InfoFetchers::OpenLibrary::Api::AuthorDetailsFetcher.new(external_identity.external_id).fetch
        if result
          save_results!(result)
        else
          save_results!(nil, errors: [StandardError.new('Failed to fetch Open Library author data')])
        end
      end

      def apply_birth_year!(year = nil)
        apply_year!(:birth_year, year, fetched_data_normalized['birth_date'])
      end

      def apply_death_year!(year = nil)
        apply_year!(:death_year, year, fetched_data_normalized['death_date'])
      end

      def apply_description!(text)
        summary = text.to_s.strip
        raise ArgumentError, 'Description is required' if summary.blank?

        author.upsert_description_from_source!(self, text: summary, source_label: nil)
      end

      def add_identity!(external_resource, external_id)
        resource = external_resource.to_s
        unless Admin::ExternalIdentity.external_resources.key?(resource)
          raise ArgumentError, 'Invalid external resource'
        end

        id = external_id.to_s.strip
        raise ArgumentError, 'External ID is required' if id.blank?

        identity = author.external_identities.create!(external_resource: resource, external_id: id)
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def add_link!(url, external_resource:)
        resource = external_resource.to_s.strip
        raise ArgumentError, 'External resource is required' if resource.blank?

        link_url = url.to_s.strip
        raise ArgumentError, 'URL is required' if link_url.blank?

        link = author.external_links.find_or_initialize_by(url: link_url)
        link.external_resource = resource
        link.save!
        link
      end

      def fetched_data_normalized
        data = fetched_data
        return {} unless data.is_a?(Hash)

        normalized_author_payload(data)
      end

      # rubocop:disable-next Metrics/MethodLength
      def normalized_author_payload(data)
        {
          'name' => data['name'],
          'personal_name' => data['personal_name'],
          'birth_date' => data['birth_date'],
          'death_date' => data['death_date'],
          'bio' => fetched_text_value(data['bio']),
          'remote_ids' => fetched_remote_ids(data['remote_ids']),
          'links' => fetched_links(data['links']),
          'photos' => fetched_photos(data['photos']),
          'revision' => data['revision']
        }.compact_blank
      end

      def applyable_remote_ids
        Array(fetched_data_normalized['remote_ids']).select do |entry|
          Admin::ExternalIdentity.external_resources.key?(entry['external_resource'].to_s)
        end
      end

      def applyable_links
        Array(fetched_data_normalized['links']).filter_map do |link|
          url = link['url'].presence
          next unless url

          resource = self.class.external_resource_from_label(link['label'])
          next if resource.blank?

          { 'external_resource' => resource, 'url' => url }
        end
      end

      def description_for_textarea
        self.class.filter_bio_reference_links(fetched_data_normalized['bio'])
      end

      def self.parse_year(date_string)
        date_string.to_s[/\b(\d{4})\b/, 1]&.to_i
      end

      # Open Library bios use markdown reference links like "[1][1]" / "[label][id]".
      def self.filter_bio_reference_links(text)
        text.to_s.gsub(/\[([^\]]+)\]\[[^\]]+\]/, '\1').presence
      end

      # Open Library link titles sometimes include boilerplate like "Author's …" / "… Author Entry".
      def self.external_resource_from_label(label)
        value = label.to_s.strip
        return if value.blank?

        value.delete_prefix("Author's ").delete_suffix(' Author Entry').strip.presence
      end

      private

      def apply_year!(attribute, year, date_string)
        value = year.presence || self.class.parse_year(date_string)
        raise ArgumentError, 'Year is required' if value.blank?

        author.update!(attribute => value.to_i)
      end

      def fetched_text_value(value)
        case value
        when Hash
          value['value'].presence
        else
          value.presence
        end
      end

      def fetched_remote_ids(remote_ids)
        return [] unless remote_ids.is_a?(Hash)

        remote_ids.filter_map do |resource, external_id|
          id = external_id.presence
          next unless id

          { 'external_resource' => resource.to_s, 'external_id' => id.to_s }
        end
      end

      def fetched_links(links)
        return [] unless links.is_a?(Array)

        links.filter_map do |link|
          next unless link.is_a?(Hash)

          url = link['url'].presence
          next unless url

          { 'label' => link['title'], 'url' => url }.compact_blank
        end
      end

      def fetched_photos(photos)
        return [] unless photos.is_a?(Array)

        photos.grep(Integer)
      end
    end
  end
end
