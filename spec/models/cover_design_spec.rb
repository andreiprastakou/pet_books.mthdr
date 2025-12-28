# == Schema Information
#
# Table name: cover_designs
# Database name: primary
#
#  id                :integer          not null, primary key
#  author_name_color :string           not null
#  author_name_font  :string           not null
#  cover_image       :string           not null
#  name              :string           not null
#  title_color       :string           not null
#  title_font        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe CoverDesign do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title_color) }
  it { is_expected.to validate_presence_of(:title_font) }
  it { is_expected.to validate_presence_of(:author_name_color) }
  it { is_expected.to validate_presence_of(:author_name_font) }
  it { is_expected.to validate_presence_of(:cover_image) }

  describe '.default' do
    subject(:result) { described_class.default }

    context 'when a default cover design is found' do
      let(:default_cover_design) { create(:cover_design, name: 'default') }

      before { default_cover_design }

      it 'returns the default cover design' do
        expect(result).to eq(default_cover_design)
      end
    end

    context 'when no default cover design is found' do
      it { is_expected.to be_nil }
    end
  end
end
