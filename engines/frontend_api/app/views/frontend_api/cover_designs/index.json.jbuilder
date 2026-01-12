# frozen_string_literal: true

json.array! @cover_designs do |cover_design|
  json.id cover_design.id
  json.name cover_design.name
  json.title_color cover_design.title_color
  json.title_font cover_design.title_font
  json.author_name_color cover_design.author_name_color
  json.author_name_font cover_design.author_name_font
  json.cover_image cover_design.cover_image
end
