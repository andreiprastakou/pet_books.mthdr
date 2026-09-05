# frozen_string_literal: true

json.partial! 'frontend_api/series/index_entries/entry', collection: @series_list, as: :series
