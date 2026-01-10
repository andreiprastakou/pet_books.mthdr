# frozen_string_literal: true

book = @book
json.id book.id
json.title book.title
json.original_title book.original_title
json.cover_thumb_url nil
json.author_id book.legacy_author_id
json.year_published book.year_published
json.tag_ids book.tag_ids
