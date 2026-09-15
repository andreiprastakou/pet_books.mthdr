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
  class OpenLibrarySearchTask < BaseDataFetchTask
    def self.setup(book)
      create!(target: book)
    end

    def self.next_unresolved(excluding: nil)
      scope = where(status: :fetched).order(:id)
      scope = scope.where.not(id: excluding.id) if excluding
      scope.first
    end

    def book
      Admin::Book.cast(target)
    end

    def perform
      results = InfoFetchers::OpenLibrary::Api::BookSearcher.new(book).search
      save_results!(results)
      results
    end

    def add_work_identity!(work_key)
      olid = InfoFetchers::OpenLibrary::Api::BookDetailsFetcher.normalize_work_key(work_key)
      raise ArgumentError, 'Invalid Open Library work key' if olid.blank?

      identity = book.external_identities.create!(
        external_resource: ExternalResources::OPEN_LIBRARY,
        external_id: olid
      )
      Admin::ExternalIdentityIntroductor.call(identity)
    end

    def add_author_identity!(author_key, author:)
      olid = ExternalLinks::OpenLibrary::Author.normalize_id(author_key)
      raise ArgumentError, 'Invalid Open Library author key' if olid.blank?
      raise ArgumentError, 'Author is required' if author.blank?
      raise ArgumentError, 'Author is not linked to this book' unless book.authors.exists?(id: author.id)

      identity = Admin::Author.cast(author).external_identities.create!(
        external_resource: ExternalResources::OPEN_LIBRARY,
        external_id: olid
      )
      Admin::ExternalIdentityIntroductor.call(identity)
    end

    def fetched_usable_values
      (fetched_data || []).map do |entry|
        author_keys = Array(entry['author_key'] || entry[:author_key])
        author_names = Array(entry['author_name'] || entry[:author_name])
        authors = author_keys.zip(author_names).to_h
        entry.slice('key', 'title', 'first_publish_year').merge('authors' => authors)
      end
    end
  end
end
