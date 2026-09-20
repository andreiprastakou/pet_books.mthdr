# frozen_string_literal: true

module Admin
  # History / pending-review helpers for entities that own data-fetch tasks.
  # Subclasses define .data_fetch_owner_type (e.g. ::Author.name).
  module HasDataFetchTaskHistory
    extend ActiveSupport::Concern

    def history_data_fetch_tasks
      owner_tasks = Admin::Tasks::BaseTask.where(target_type: self.class.data_fetch_owner_type, target_id: id)
      identity_tasks = Admin::Tasks::BaseTask.where(
        target_type: Admin::ExternalIdentity.name, target_id: external_identities.select(:id)
      )
      merge_tasks_by_updated_at(owner_tasks, identity_tasks)
    end

    def merge_tasks_by_updated_at(*scopes)
      scopes.flat_map(&:to_a).sort_by(&:updated_at).reverse
    end

    def pending_review_data_fetch_tasks
      Admin::Tasks::BaseTask.pending_review_tasks_for(self)
    end
  end
end
