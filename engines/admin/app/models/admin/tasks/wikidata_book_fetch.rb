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
    class WikidataBookFetch < BaseTask
      def self.setup(external_identity)
        create!(target: external_identity)
      end

      alias external_identity target

      def book
        owner = external_identity.owner
        raise ArgumentError, 'Wikidata fetch target must belong to a book' unless owner.is_a?(::Book)

        Admin::Book.cast(owner)
      end

      def perform
        result = Admin::InfoFetchers::Wikidata::Api::BookDetailsFetcher.new(external_identity.external_id).fetch
        if result
          save_results!(result)
          cache_lookup_entities!(result)
        else
          save_results!(nil, errors: [StandardError.new('Failed to fetch Wikidata item data')])
        end
      end

      def apply_year!(year = nil)
        value = year.presence || self.class.parse_year(fetched_data_normalized['publication_date'])
        raise ArgumentError, 'Year is required' if value.blank?

        book.update!(year_published: value.to_i)
      end

      def apply_literary_form!(literary_form)
        value = literary_form.to_s.strip
        raise ArgumentError, 'Literary form is required' if value.blank?

        book.update!(literary_form: value)
      end

      def add_identity!(external_resource, external_id)
        resource = external_resource.to_s
        unless Admin::ExternalIdentity.external_resources.key?(resource)
          raise ArgumentError, 'Invalid external resource'
        end

        id = external_id.to_s.strip
        raise ArgumentError, 'External ID is required' if id.blank?

        identity = book.external_identities.create!(external_resource: resource, external_id: id)
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def add_author_identity!(entity_id, author:)
        qid = Admin::ExternalLinkBuilders::Wikidata.normalize_id(entity_id)
        raise ArgumentError, 'Invalid Wikidata entity id' if qid.blank?
        raise ArgumentError, 'Author is required' if author.blank?
        raise ArgumentError, 'Author is not linked to this book' unless book.authors.exists?(id: author.id)

        identity = Admin::Author.cast(author).external_identities.create!(
          external_resource: ExternalResources::WIKIDATA,
          external_id: qid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end

      def add_genre_identity!(entity_id, genre:)
        qid = validate_wikidata_entity_id!(entity_id)
        raise ArgumentError, 'Genre is required' if genre.blank?

        admin_genre = Admin::Genre.cast(genre)
        identity = find_or_create_wikidata_identity!(admin_genre, qid)
        book.genres.find_or_create_by!(genre_id: admin_genre.id)
        identity
      end

      def add_series_identity!(entity_id, series:)
        qid = validate_wikidata_entity_id!(entity_id)
        raise ArgumentError, 'Series is required' if series.blank?

        admin_series = Admin::Series.cast(series)
        identity = find_or_create_wikidata_identity!(admin_series, qid)
        book.book_series.find_or_create_by!(series_id: admin_series.id)
        identity
      end

      def validate_wikidata_entity_id!(entity_id)
        qid = Admin::ExternalLinkBuilders::Wikidata.normalize_id(entity_id)
        raise ArgumentError, 'Invalid Wikidata entity id' if qid.blank?

        qid
      end

      def find_or_create_wikidata_identity!(owner, qid)
        identity = owner.external_identities.wikidata.find_by(external_id: qid)
        return identity if identity

        identity = owner.external_identities.create!(
          external_resource: ExternalResources::WIKIDATA,
          external_id: qid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
        identity
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
        values = Admin::Wikidata::BookUsableValues.call(fetched_data)
        Admin::Wikidata::EntityLookup.enrich(values, fetch_missing: true)
      end

      def applyable_external_identities
        Array(fetched_data_normalized['external_identities']).select do |entry|
          Admin::ExternalIdentity.external_resources.key?(entry['external_resource'].to_s)
        end
      end

      def wikipedia_sitelinks
        Array(fetched_data_normalized['sitelinks']).select { |link| self.class.wikipedia_url?(link['url']) }
      end

      def other_sitelinks
        Array(fetched_data_normalized['sitelinks']).filter_map do |link|
          url = link['url'].presence
          next if url.blank? || self.class.wikipedia_url?(url)

          host = self.class.host_from_url(url)
          next if host.blank?

          { 'external_resource' => host, 'url' => url }
        end
      end

      def self.parse_year(date_string)
        date_string.to_s[/\b(\d{4})\b/, 1]&.to_i
      end

      def self.wikipedia_url?(url)
        host = host_from_url(url)
        host.present? && host.end_with?('wikipedia.org')
      end

      def self.host_from_url(url)
        URI.parse(url.to_s.strip).host.presence
      rescue URI::InvalidURIError
        nil
      end

      private

      def cache_lookup_entities!(result)
        data = Admin::Wikidata::BookUsableValues.call(result)
        Admin::Wikidata::EntityLookup.cache_from_item!(result, data: data)
      end
    end
  end
end
