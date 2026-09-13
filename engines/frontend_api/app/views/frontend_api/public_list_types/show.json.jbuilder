# frozen_string_literal: true

json.id @public_list_type.id
json.name @public_list_type.name
json.external_links(@public_list_type.external_links.map { |link| { external_resource: link.external_resource, url: link.url } })
json.public_lists @public_list_type.public_lists.order(year: :desc) do |public_list|
  json.id public_list.id
  json.year public_list.year
end
