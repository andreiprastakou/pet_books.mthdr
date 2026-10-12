# frozen_string_literal: true

# == Schema Information
#
# Table name: user_book_reads
# Database name: primary
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_book_reads_on_book_id              (book_id)
#  index_user_book_reads_on_user_id_and_book_id  (user_id,book_id) UNIQUE
#
# Foreign Keys
#
#  book_id  (book_id => books.id)
#  user_id  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe UserBookRead do
  subject { create(:user_book_read) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).required }
    it { is_expected.to belong_to(:book).required }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:book_id).scoped_to(:user_id) }
  end

  describe '.read_ids_among' do
    let(:user) { create(:user) }
    let(:read_book) { create(:book) }
    let(:unread_book) { create(:book) }
    let(:other_book) { create(:book) }

    before do
      create(:user_book_read, user: user, book: read_book)
      create(:user_book_read, user: create(:user), book: unread_book)
    end

    it 'returns only the given user reads among the requested books' do
      ids = described_class.read_ids_among(user, [read_book.id, unread_book.id, other_book.id])

      expect(ids).to eq([read_book.id])
    end

    it 'returns nothing when no books are requested' do
      expect(described_class.read_ids_among(user, [])).to eq([])
    end
  end

  describe '.mark!' do
    let(:user) { create(:user) }

    it 'marks a book that is not a collection' do
      book = create(:book)

      expect(described_class.mark!(user, book)).to eq([])
      expect(described_class.read?(user, book)).to be(true)
    end

    it 'marks a collection and its unread included works' do
      collection = create(:book, literary_form: 'collection')
      already_read = create(:book)
      unread_work = create(:book)
      create(:book_collection, collection: collection, book: already_read)
      create(:book_collection, collection: collection, book: unread_work)
      create(:user_book_read, user: user, book: already_read)

      included_ids = described_class.mark!(user, collection)

      expect(included_ids).to contain_exactly(already_read.id, unread_work.id)
      expect(described_class.where(user: user, book: already_read).count).to eq(1)
      expect(described_class.read?(user, unread_work)).to be(true)
      expect(described_class.read?(user, collection)).to be(true)
    end

    it 'marks an empty collection without included works' do
      collection = create(:book, literary_form: 'collection')

      expect(described_class.mark!(user, collection)).to eq([])
      expect(described_class.read?(user, collection)).to be(true)
    end
  end

  describe '.read?' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }

    it 'is true only after that user marks the book' do
      expect(described_class.read?(user, book)).to be(false)

      create(:user_book_read, user: user, book: book)

      expect(described_class.read?(user, book)).to be(true)
    end
  end
end
