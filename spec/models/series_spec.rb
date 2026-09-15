# frozen_string_literal: true

# == Schema Information
#
# Table name: series
# Database name: primary
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_series_on_name  (name)
#
require 'rails_helper'

RSpec.describe Series do
  describe 'associations' do
    it { is_expected.to have_many(:book_series).class_name(Joins::BookSeries.name) }
    it { is_expected.to have_many(:books).class_name(Book.name).through(:book_series) }
  end

  describe 'validation' do
    subject { build(:series) }

    it { is_expected.to validate_presence_of(:name) }

    it 'has a valid factory' do
      expect(build(:series)).to be_valid
    end
  end

  describe 'scopes' do
    describe '.search_by_name' do
      subject(:result) { described_class.search_by_name(key) }

      let(:key) { 'Earth' }
      let(:matching) { create(:series, name: 'Earthsea') }
      let(:other) { create(:series, name: 'Dune') }

      before { [matching, other] }

      it 'returns series matching the key' do
        expect(result).to contain_exactly(matching)
      end
    end
  end

  describe '#==' do
    it 'equates Admin::Series and Series with the same id' do
      admin_series = create(:series)
      expect(described_class.find(admin_series.id)).to eq(admin_series)
    end
  end

  describe '#readonly?' do
    it 'is readonly' do
      expect(described_class.new).to be_readonly
      expect(described_class.find(create(:series).id)).to be_readonly
    end

    it 'rejects persistence' do
      series = described_class.find(create(:series).id)
      expect { series.update!(name: 'OTHER') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  it_behaves_like 'has external links'
end
