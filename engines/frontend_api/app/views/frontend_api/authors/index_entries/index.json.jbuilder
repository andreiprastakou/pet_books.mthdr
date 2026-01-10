# frozen_string_literal: true

counts_by_author = Book.joins(:book_authors).group(book_authors: :author_id).count

json.list do
  json.partial! 'frontend_api/authors/index_entries/author', collection: @authors, as: :author,
                                                             counts_by_author: counts_by_author
end
json.total @count
