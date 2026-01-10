# frozen_string_literal: true

json.array! @series do |series|
  json.id series.id
  json.label series.name
end
