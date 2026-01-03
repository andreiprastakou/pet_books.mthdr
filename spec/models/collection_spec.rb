# == Schema Information
#
# Table name: collections
# Database name: primary
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  wiki_url       :string
#  year_published :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_collections_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Collection do
  subject { build(:collection) }

  describe 'associations' do
    it { is_expected.to have_many(:book_collections).class_name(BookCollection.name) }
    it { is_expected.to have_many(:books).class_name(Book.name).through(:book_collections) }
  end

  describe 'validation' do
    subject { build(:collection) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:year_published) }
    it { is_expected.to validate_numericality_of(:year_published).only_integer }

    it 'has a valid factory' do
      expect(build(:collection)).to be_valid
    end
  end

  it_behaves_like 'has wiki links' do
    let(:record) { build(:collection) }
  end
end
