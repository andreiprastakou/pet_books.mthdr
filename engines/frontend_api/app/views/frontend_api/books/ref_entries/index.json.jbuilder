# frozen_string_literal: true

json.list do
  json.array! @books do |book|
    json.id book.id
    json.author_id book.legacy_author_id
    json.year book.year_published
  end
end
json.total @count
