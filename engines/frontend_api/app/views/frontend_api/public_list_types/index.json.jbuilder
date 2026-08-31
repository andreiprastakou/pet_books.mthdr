# frozen_string_literal: true

json.array! @public_list_types do |public_list_type|
  json.id public_list_type.id
  json.name public_list_type.name
end
