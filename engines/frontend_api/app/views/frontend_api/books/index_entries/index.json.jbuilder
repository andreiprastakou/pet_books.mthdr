# frozen_string_literal: true

json.array! @books do |book|
  json.id book.id
  json.title book.title
  json.author_ids book.author_ids
  json.year book.year_published
  json.tag_ids book.tag_ids
  json.popularity book.popularity
  json.global_rank 0
  json.cover_design_id book_cover_design(book).id
  json.small book.small?
end
