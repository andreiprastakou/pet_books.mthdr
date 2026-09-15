# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
# Database name: primary
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  year_published :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_collections_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Admin::Collection do
  it 'has a valid factory' do
    expect(build(:admin_collection)).to be_valid
  end

  it_behaves_like 'has wikipedia' do
    let(:record) { build(:admin_collection) }
  end

  describe '#readonly?' do
    it 'is writable' do
      expect(described_class.new).not_to be_readonly
      expect(create(:admin_collection)).not_to be_readonly
    end
  end

  describe '#book_ids=' do
    subject(:call) { collection.book_ids = book_ids }

    let(:collection) { create(:admin_collection, book_collections: initial_book_collections) }
    let(:books) { create_list(:book, 3) }
    let(:initial_book_collections) do
      [build(:book_collection, book: books[0]), build(:book_collection, book: books[1])]
    end
    let(:book_ids) { [books[1].id, books[2].id, ''] }

    it 'assigns the books by given ids' do
      collection
      expect { call }.not_to change(Joins::BookCollection, :count)
      expect(collection.book_collections.map(&:book_id)).to eq(books[0..2].map(&:id))
      expect(collection.book_collections.map(&:marked_for_destruction?)).to eq([true, false, false])
      expect(collection.book_collections.map(&:new_record?)).to eq([false, false, true])
    end
  end
end
