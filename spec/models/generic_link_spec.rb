# == Schema Information
#
# Table name: generic_links
# Database name: primary
#
#  id          :integer          not null, primary key
#  entity_type :string           not null
#  locale      :string
#  name        :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_id   :integer          not null
#
# Indexes
#
#  index_generic_links_on_entity_type_and_entity_id  (entity_type,entity_id)
#
require 'rails_helper'

RSpec.describe GenericLink do
  subject(:link) { build(:generic_link) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:entity_type) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }

    it 'has a valid factory' do
      expect(build(:generic_link, entity: build_stubbed(:book))).to be_valid
    end
  end
end
