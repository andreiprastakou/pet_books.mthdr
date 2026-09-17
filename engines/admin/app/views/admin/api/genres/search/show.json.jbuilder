# frozen_string_literal: true

json.array! @genres do |genre|
  json.id genre.id
  json.label genre.name
end
