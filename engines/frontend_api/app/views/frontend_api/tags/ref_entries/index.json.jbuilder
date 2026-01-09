# frozen_string_literal: true

# json.partial! 'api/tags/ref_entries/entry', collection: @tags, as: :tag

json.array! @tags do |tag|
  json.id tag.id
  json.name tag.name
  json.category_id Tag.categories[tag.category]
  json.connections_count tag.book_tag_connections.size
end
