# == Schema Information
#
# Table name: genres
# Database name: primary
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cover_design_id :integer
#
# Indexes
#
#  index_genres_on_cover_design_id  (cover_design_id)
#  index_genres_on_name             (name) UNIQUE
#
# Foreign Keys
#
#  cover_design_id  (cover_design_id => cover_designs.id)
#
require 'rails_helper'

RSpec.describe Genre do
  subject { build(:genre) }

  describe 'associations' do
    it { is_expected.to belong_to(:cover_design).class_name(CoverDesign.name).optional }
    it { is_expected.to have_many(:book_genres).class_name(BookGenre.name) }
    it { is_expected.to have_many(:books).class_name(Book.name).through(:book_genres) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

    it 'has a valid factory' do
      expect(build(:genre)).to be_valid
    end
  end

  it_behaves_like 'has codified name', :name do
    let(:record) { build(:genre) }
  end
end
