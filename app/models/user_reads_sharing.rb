# frozen_string_literal: true

# == Schema Information
#
# Table name: user_reads_sharings
# Database name: primary
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_reads_sharings_on_code     (code) UNIQUE
#  index_user_reads_sharings_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class UserReadsSharing < ApplicationRecord
  CODE_FORMAT = /\A[0-9a-f]{16}\z/

  belongs_to :user

  validates :code, presence: true, uniqueness: true, format: { with: CODE_FORMAT }
  validates :user_id, uniqueness: true

  before_validation :assign_code, on: :create

  def self.ensure_for!(user)
    find_by(user: user) || create!(user: user)
  rescue ActiveRecord::RecordNotUnique
    found = find_by(user: user)
    return found if found

    retry
  end

  def self.unused_code
    loop do
      candidate = SecureRandom.hex(8)
      break candidate unless exists?(code: candidate)
    end
  end

  private

  def assign_code
    self.code = self.class.unused_code if code.blank?
  end
end
