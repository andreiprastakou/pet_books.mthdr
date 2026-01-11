# frozen_string_literal: true

book = @book
json.id book.id
json.title book.title
json.original_title book.original_title
json.author_ids book.author_ids
json.year_published book.year_published
json.tag_ids book.tag_ids
json.small book.small?
