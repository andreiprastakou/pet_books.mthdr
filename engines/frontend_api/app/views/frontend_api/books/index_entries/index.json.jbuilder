# frozen_string_literal: true

json.array! @books do |book|
  json.id book.id
  json.title book.title
  json.cover_thumb_url nil
  json.author_id book.legacy_author_id
  json.year book.year_published
  json.tag_ids book.tag_ids
  json.popularity book.popularity
  json.global_rank 0
  json.cover_design_id book.pick_cover_design_id
end
