# frozen_string_literal: true

json.array! @tags do |tag|
  json.id tag.id
  json.label tag.name
end
