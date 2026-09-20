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
    class WikidataAuthorWorksFetch < BaseTask
      def self.setup(external_identity)
        owner = external_identity.owner
        raise ArgumentError, 'Wikidata author works fetch target must belong to an author' unless owner.is_a?(::Author)

        create!(
          target: owner,
          input_data: { 'entity_id' => external_identity.external_id }
        )
      end

      def author
        return @author if defined?(@author)

        @author = Admin::Author.cast(target)
        ActiveRecord::Associations::Preloader.new(
          records: [@author],
          associations: %i[external_links wiki_links]
        ).call
        @author
      end

      def entity_id
        input_data&.dig('entity_id').presence ||
          author.external_identities.wikidata.first&.external_id
      end

      def perform
        qid = entity_id
        return save_missing_entity_error! if qid.blank?

        result = Admin::InfoFetchers::Wikidata::Api::AuthorWorksFetcher.new(qid).fetch
        result ? save_results!(result) : save_fetch_failure!
      end

      def self.parse_year(date_string)
        date_string.to_s[/\b(\d{4})\b/, 1]&.to_i
      end

      def apply_work!(title:, year:, book_id: nil, entity_id: nil)
        book_title, year_value = validated_title_and_year!(title, year)
        qid = Admin::ExternalLinkBuilders::Wikidata.normalize_id(entity_id)

        book = find_or_build_book!(book_id)
        book.title = book_title
        book.year_published = year_value.to_i
        book.save!
        ensure_wikidata_identity!(book, qid) if qid.present?
        book
      end

      private

      def save_missing_entity_error!
        save_results!(nil, errors: [StandardError.new('Author has no Wikidata identity')])
      end

      def save_fetch_failure!
        save_results!(nil, errors: [StandardError.new('Failed to fetch Wikidata author works')])
      end

      def validated_title_and_year!(title, year)
        book_title = title.to_s.strip
        raise ArgumentError, 'Title is required' if book_title.blank?

        year_value = self.class.parse_year(year).presence || year.to_s.strip.presence
        raise ArgumentError, 'Year is required' if year_value.blank?

        [book_title, year_value]
      end

      def find_or_build_book!(book_id)
        return Admin::Book.new(authors: [author]) if book_id.blank?

        Admin::Book.for_scope(
          author.books.where(id: book_id),
          :external_links, :wiki_links, :external_identities
        ).first!
      end

      def ensure_wikidata_identity!(book, qid)
        return if book.external_identities.wikidata.exists?(external_id: qid)

        identity = book.external_identities.create!(
          external_resource: ExternalResources::WIKIDATA,
          external_id: qid
        )
        Admin::ExternalIdentityIntroductor.call(identity)
      end
    end
  end
end
