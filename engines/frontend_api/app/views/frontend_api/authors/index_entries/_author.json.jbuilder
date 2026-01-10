# frozen_string_literal: true

json.id author.id
json.fullname author.fullname
json.books_count counts_by_author.fetch(author.id, 0)
json.thumb_url author.photo_thumb_url
json.birth_year author.birth_year
json.rank 0
