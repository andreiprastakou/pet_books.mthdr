# frozen_string_literal: true

json.id @public_list.id
json.public_list_type_id @public_list.public_list_type_id
json.year @public_list.year
json.wiki_url @public_list.wiki_url
json.generic_links @public_list.generic_links.map { |link| { name: link.name, url: link.url } }
json.books @public_list.book_public_lists do |book_public_list|
  json.id book_public_list.book_id
  json.role book_public_list.role
end
