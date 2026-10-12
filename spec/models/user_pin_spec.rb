# frozen_string_literal: true

# == Schema Information
#
# Table name: user_pins
# Database name: primary
#
#  id          :integer          not null, primary key
#  entity_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_id   :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_user_pins_on_entity_type_and_entity_id              (entity_type,entity_id)
#  index_user_pins_on_user_id_and_entity_type_and_entity_id  (user_id,entity_type,entity_id) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe UserPin do
  subject { create(:user_pin) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).required }
    it { is_expected.to belong_to(:entity).required }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:entity_id).scoped_to(:user_id, :entity_type) }
  end

  describe '.pinned?' do
    let(:user) { create(:user) }

    it 'is true only for entities that user has pinned' do
      pinned = [create(:book), create(:author), create(:series), create(:public_list)]
      other = create(:book)
      pinned.each { |entity| create(:user_pin, user: user, entity: entity) }

      expect(pinned).to all(satisfy { |entity| described_class.pinned?(user, entity) })
      expect(described_class.pinned?(user, other)).to be(false)
      expect(described_class.pinned?(create(:user), pinned.first)).to be(false)
    end
  end
end
