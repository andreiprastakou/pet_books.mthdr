# frozen_string_literal: true

json.id @public_list.id
json.public_list_type_id @public_list.public_list_type_id
json.year @public_list.year
json.external_links(@public_list.external_links.map { |link| { external_resource: link.external_resource, url: link.url } })
json.books @public_list.book_public_lists do |book_public_list|
  json.id book_public_list.book_id
  json.role book_public_list.role
end
