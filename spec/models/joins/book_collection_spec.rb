# frozen_string_literal: true

# == Schema Information
#
# Table name: book_collections
# Database name: primary
#
#  id            :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  book_id       :integer          not null
#  collection_id :integer          not null
#
# Indexes
#
#  index_book_collections_on_book_id                    (book_id)
#  index_book_collections_on_collection_id_and_book_id  (collection_id,book_id) UNIQUE
#
# Foreign Keys
#
#  book_id        (book_id => books.id)
#  collection_id  (collection_id => books.id)
#
require 'rails_helper'

RSpec.describe Joins::BookCollection do
  subject { build(:book_collection) }

  describe 'associations' do
    it { is_expected.to belong_to(:book).class_name('Book').required }
    it { is_expected.to belong_to(:collection).class_name('Book').required }
  end

  describe 'validation' do
    let(:collection_book) { create(:book, literary_form: 'collection') }
    let(:work) { create(:book, literary_form: 'novel') }

    it 'has a valid factory' do
      expect(build(:book_collection, collection: collection_book, book: work)).to be_valid
    end

    it 'rejects a book linked to itself' do
      join = build(:book_collection, collection: collection_book, book: collection_book)

      expect(join).not_to be_valid
      expect(join.errors[:book]).to include('must be different from the collection')
    end

    it 'requires the collection book to have literary form collection' do
      join = build(:book_collection, collection: work, book: create(:book, literary_form: 'novella'))

      expect(join).not_to be_valid
      expect(join.errors[:collection]).to include('must have literary form collection')
    end

    it 'rejects a collected work that has literary form collection' do
      join = build(:book_collection, collection: collection_book, book: create(:book, literary_form: 'collection'))

      expect(join).not_to be_valid
      expect(join.errors[:book]).to include('must not have literary form collection')
    end
  end
end
