# frozen_string_literal: true

module Admin
  module Tasks
    module UnresolvedSearchable
      extend ActiveSupport::Concern

      class_methods do
        def next_unresolved(excluding: nil)
          scope = where(status: :fetched).order(:id)
          scope = scope.where.not(id: excluding.id) if excluding
          scope.first
        end
      end
    end
  end
end
