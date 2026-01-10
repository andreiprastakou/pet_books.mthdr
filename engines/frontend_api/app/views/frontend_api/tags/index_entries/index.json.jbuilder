# frozen_string_literal: true

json.partial! 'frontend_api/tags/index_entries/entry', collection: @tags, as: :tag
