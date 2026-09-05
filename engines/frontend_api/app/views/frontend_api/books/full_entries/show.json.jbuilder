# frozen_string_literal: true

book = @book
json.id book.id
json.title book.title
json.original_title book.original_title
json.author_ids book.author_ids
json.year_published book.year_published
json.tag_ids book.tag_ids
json.series_ids book.series_ids
json.small book.small?
json.summary book.summary
json.wiki_url book.wiki_url
json.generic_links book.generic_links.map { |link| { name: link.name, url: link.url } }
