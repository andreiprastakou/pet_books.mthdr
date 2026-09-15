# frozen_string_literal: true

module Admin
  class AiRecord < ApplicationRecord
    self.abstract_class = true

    # Override engine's `admin_` prefix from isolate_namespace.
    def self.full_table_name_prefix
      'ai_'
    end
  end
end
