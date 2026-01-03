# frozen_string_literal: true

author = @author
json.id author.id
json.fullname author.fullname
json.photo_thumb_url author.photo_thumb_url
json.photo_full_url author.photo_url
json.reference author.wiki_url
json.birth_year author.birth_year
json.death_year author.death_year
json.tag_ids author.tag_ids
json.books_count author.books.count
json.popularity author.popularity
json.rank 0
