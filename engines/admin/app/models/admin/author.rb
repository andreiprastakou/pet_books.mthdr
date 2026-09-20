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
    include Admin::Castable
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities
    include Admin::HasDataFetchTaskHistory

    has_many :books, class_name: 'Admin::Book', through: :book_authors
    has_many :books_list_tasks, class_name: 'Admin::Tasks::AiAuthorWorksFetch', as: :target, dependent: :destroy
    has_many :list_parsing_tasks, class_name: 'Admin::Tasks::AiAuthorWorksParse', as: :target, dependent: :destroy
    has_many :open_library_author_search_tasks, class_name: 'Admin::Tasks::OpenLibraryAuthorSearch', as: :target,
                                                dependent: :destroy

    scope :not_synced, -> { where(synced_at: nil) }
    scope :without_tasks, -> { where.missing(:books_list_tasks).where.missing(:list_parsing_tasks) }

    def self.data_fetch_owner_type
      ::Author.name
    end
  end
end
