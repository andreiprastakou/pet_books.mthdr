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

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to have_secure_password }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  it 'stores a normalized email' do
    user = create(:user, email: '  Reader@Example.com ')

    expect(user.reload.email).to eq('reader@example.com')
  end

  it 'rejects a short password' do
    user = build(:user, password: 'short')

    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end

  it 'authenticates with the password' do
    user = create(:user, password: AuthHelper::FRONTEND_PASSWORD)

    expect(user.authenticate(AuthHelper::FRONTEND_PASSWORD)).to eq(user)
    expect(user.authenticate('not-the-password')).to be false
  end
end
