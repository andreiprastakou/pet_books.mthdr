# frozen_string_literal: true

# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password

  has_many :user_book_reads, dependent: :delete_all
  has_many :read_books, through: :user_book_reads, source: :book
  has_many :user_pins, dependent: :delete_all
  has_one :user_pins_sharing, dependent: :destroy
  has_one :user_reads_sharing, dependent: :destroy

  before_validation :normalize_email

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
