# frozen_string_literal: true

json.array! @series_list do |series|
  json.series_id series.id
  json.label series.name
end
