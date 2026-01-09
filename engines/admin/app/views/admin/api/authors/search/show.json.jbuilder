# frozen_string_literal: true

json.array! @authors do |author|
  json.id author.id
  json.label author.fullname
end
