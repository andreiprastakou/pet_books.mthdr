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
require 'rails_helper'

RSpec.describe UserReadsSharing do
  subject { create(:user_reads_sharing) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }
    it { is_expected.to validate_uniqueness_of(:user_id) }
    it { is_expected.to allow_value('a' * 16).for(:code) }
    it { is_expected.not_to allow_value('A' * 16).for(:code) }
    it { is_expected.not_to allow_value('short').for(:code) }
  end

  describe '.ensure_for!' do
    let(:user) { create(:user) }

    it 'creates one 16-character hex code and reuses it' do
      first = described_class.ensure_for!(user)
      second = described_class.ensure_for!(user)

      expect(second).to eq(first)
      expect(first.code).to match(/\A[0-9a-f]{16}\z/)
      expect(described_class.where(user: user).count).to eq(1)
    end
  end
end
