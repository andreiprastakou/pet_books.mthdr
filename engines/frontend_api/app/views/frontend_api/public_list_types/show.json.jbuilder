# frozen_string_literal: true

json.id @public_list_type.id
json.name @public_list_type.name
json.wiki_url @public_list_type.wiki_url
json.generic_links(@public_list_type.generic_links.map { |link| { name: link.name, url: link.url } })
json.public_lists @public_list_type.public_lists.order(year: :desc) do |public_list|
  json.id public_list.id
  json.year public_list.year
end
