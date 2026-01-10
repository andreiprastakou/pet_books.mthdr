# frozen_string_literal: true

json.array! @books do |book|
  json.id book.id
  json.label book_label_for_badges(book)
end
