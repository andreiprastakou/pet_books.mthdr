# frozen_string_literal: true

module HasSharingCode
  extend ActiveSupport::Concern

  CODE_FORMAT = /\A[0-9a-f]{16}\z/

  included do
    belongs_to :user

    validates :code, presence: true, uniqueness: true, format: { with: CODE_FORMAT }
    validates :user_id, uniqueness: true

    before_validation :assign_code, on: :create
  end

  class_methods do
    def ensure_for!(user)
      find_by(user: user) || create!(user: user)
    rescue ActiveRecord::RecordNotUnique
      found = find_by(user: user)
      return found if found

      retry
    end

    def unused_code
      loop do
        candidate = SecureRandom.hex(8)
        break candidate unless exists?(code: candidate)
      end
    end
  end

  private

  def assign_code
    self.code = self.class.unused_code if code.blank?
  end
end
