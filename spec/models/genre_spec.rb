# frozen_string_literal: true

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
  describe 'associations' do
    it { is_expected.to belong_to(:cover_design).class_name(CoverDesign.name).optional }
    it { is_expected.to have_many(:book_genres).class_name(Joins::BookGenre.name) }
    it { is_expected.to have_many(:books).class_name(Book.name).through(:book_genres) }
  end

  describe 'validations' do
    subject { build(:genre) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

    it 'has a valid factory' do
      expect(build(:genre)).to be_valid
    end
  end

  describe '#==' do
    it 'equates Admin::Genre and Genre with the same id' do
      admin_genre = create(:genre)
      expect(described_class.find(admin_genre.id)).to eq(admin_genre)
    end
  end

  describe '#readonly?' do
    it 'is readonly' do
      expect(described_class.new).to be_readonly
      expect(described_class.find(create(:genre).id)).to be_readonly
    end

    it 'rejects persistence' do
      genre = described_class.find(create(:genre).id)
      expect { genre.update!(name: 'OTHER') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  it_behaves_like 'has codified name', :name do
    let(:record) { build(:genre) }
  end
end
