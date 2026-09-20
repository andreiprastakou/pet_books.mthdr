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
    class WikidataBookFetch < BaseTask
      include Admin::Tasks::ExternalIdentityFetchable
      include Admin::Tasks::AttachesWikidataAuthorIdentity
      include Admin::Tasks::WikidataFetchHelpers
      include Admin::Tasks::WikidataDetailsFetchable

      def book
        cast_identity_owner!(
          ::Book,
          Admin::Book,
          'Wikidata fetch target must belong to a book'
        )
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

      RELATED_IDENTITY_TYPES = {
        genre: [Admin::Genre, ->(book, genre) { book.genres.find_or_create_by!(genre_id: genre.id) }],
        series: [Admin::Series, ->(book, series) { book.book_series.find_or_create_by!(series_id: series.id) }]
      }.freeze

      RELATED_IDENTITY_TYPES.each do |key, (cast_class, after_attach)|
        define_method(:"add_#{key}_identity!") do |entity_id, **kwargs|
          owner = kwargs.fetch(key)
          add_linked_wikidata_identity!(
            entity_id,
            owner: owner,
            cast_class: cast_class,
            after_attach: ->(admin_owner) { instance_exec(book, admin_owner, &after_attach) },
            label: key.to_s.capitalize
          )
        end
      end

      private

      def details_fetcher
        Admin::InfoFetchers::Wikidata::Api::BookDetailsFetcher.new(external_identity.external_id)
      end

      def usable_values_class
        Admin::Wikidata::BookUsableValues
      end

      def fetch_failure_message
        'Failed to fetch Wikidata item data'
      end

      def add_linked_wikidata_identity!(entity_id, owner:, cast_class:, after_attach:, label:)
        qid = validate_wikidata_entity_id!(entity_id)
        raise ArgumentError, "#{label} is required" if owner.blank?

        admin_owner = cast_class.cast(owner)
        identity = find_or_create_wikidata_identity!(admin_owner, qid)
        after_attach.call(admin_owner)
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

        create_introduced_identity!(owner, external_resource: ExternalResources::WIKIDATA, external_id: qid)
      end
    end
  end
end
