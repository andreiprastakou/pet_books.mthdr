# frozen_string_literal: true

json.list do
  json.array! @books do |book|
    json.id book.id
    json.author_ids book.author_ids
    json.year book.year_published
  end
end
json.total @count
