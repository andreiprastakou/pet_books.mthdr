# frozen_string_literal: true

json.array! @books do |book|
  json.book_id book.id
  json.title book.title
  json.year book.year_published
  json.author_id book.author_ids.first
end
