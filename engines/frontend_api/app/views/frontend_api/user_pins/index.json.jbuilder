# frozen_string_literal: true

json.authors(@authors) do |author|
  json.id author.id
  json.fullname author.fullname
end

json.books(@books) do |book|
  json.id book.id
  json.title book.title
  json.year book.year_published
  json.authors book.author_names_label
end

json.series(@series_list) do |series|
  json.id series.id
  json.name series.name
end
