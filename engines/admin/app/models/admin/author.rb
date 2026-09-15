# frozen_string_literal: true

# == Schema Information
#
# Table name: authors
# Database name: primary
#
#  id                :integer          not null, primary key
#  aws_photos        :json
#  birth_year        :integer
#  death_year        :integer
#  fullname          :string           not null
#  original_fullname :string
#  synced_at         :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_authors_on_fullname  (fullname) UNIQUE
#
module Admin
  class Author < ::Author
    include HasWikipedia
    include HasExternalIdentities

    has_many :books, class_name: 'Admin::Book', through: :book_authors
    has_many :books_list_tasks, class_name: 'Admin::AuthorBooksListTask', as: :target, dependent: :destroy
    has_many :list_parsing_tasks, class_name: 'Admin::AuthorBooksListParsingTask', as: :target, dependent: :destroy
    has_many :open_library_author_search_tasks, class_name: 'Admin::OpenLibraryAuthorSearchTask', as: :target,
                                                dependent: :destroy

    scope :not_synced, -> { where(synced_at: nil) }
    scope :without_tasks, -> { where.missing(:books_list_tasks).where.missing(:list_parsing_tasks) }

    def readonly?
      false
    end

    def self.cast(author)
      return author if author.is_a?(self)
      return new(author.attributes) if author.new_record?

      author.becomes(self)
    end

    def history_data_fetch_tasks
      author_fetch_tasks = Admin::BaseDataFetchTask.where(
        target_type: ::Author.name,
        target_id: id
      )
      identities_fetch_tasks = Admin::BaseDataFetchTask.where(
        target_type: Admin::ExternalIdentity.name,
        target_id: external_identities.select(:id)
      )
      (author_fetch_tasks.to_a + identities_fetch_tasks.to_a)
        .sort_by(&:updated_at)
        .reverse
    end
  end
end
