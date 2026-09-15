# frozen_string_literal: true

# == Schema Information
#
# Table name: external_api_rate_limits
# Database name: primary
#
#  id                   :integer          not null, primary key
#  last_requested_at    :datetime
#  min_interval_seconds :float            not null
#  name                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_external_api_rate_limits_on_name  (name) UNIQUE
#
module Admin
  class ExternalApiRateLimit < ApplicationRecord
    self.table_name = 'external_api_rate_limits'

    validates :name, presence: true, uniqueness: true
    validates :min_interval_seconds, presence: true, numericality: { greater_than: 0 }

    # Claims the next request slot under a row lock, then sleeps outside the transaction
    # so SQLite is not write-locked during the wait.
    def self.throttle!(name, min_interval_seconds:)
      wait = claim_slot!(name, min_interval_seconds: min_interval_seconds)
      sleep(wait) if wait.positive?
    end

    def self.claim_slot!(name, min_interval_seconds:)
      ensure_record!(name, min_interval_seconds)

      transaction do
        record = lock.find_by!(name: name)
        now = Time.current
        wait = if record.last_requested_at
                 [(record.last_requested_at + record.min_interval_seconds) - now, 0.0].max
               else
                 0.0
               end

        record.update!(
          last_requested_at: now + wait,
          min_interval_seconds: min_interval_seconds
        )
        wait
      end
    end

    def self.ensure_record!(name, min_interval_seconds)
      find_or_create_by!(name: name) do |record|
        record.min_interval_seconds = min_interval_seconds
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      find_by!(name: name)
    end
    private_class_method :ensure_record!
  end
end
