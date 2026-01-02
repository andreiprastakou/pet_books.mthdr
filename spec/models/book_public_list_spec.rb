# frozen_string_literal: true

# == Schema Information
#
# Table name: book_public_lists
# Database name: primary
#
#  id             :integer          not null, primary key
#  role           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  book_id        :integer          not null
#  public_list_id :integer          not null
#
# Indexes
#
#  index_book_public_lists_on_book_id                     (book_id)
#  index_book_public_lists_on_book_id_and_public_list_id  (book_id,public_list_id) UNIQUE
#  index_book_public_lists_on_public_list_id              (public_list_id)
#
# Foreign Keys
#
#  book_id         (book_id => books.id)
#  public_list_id  (public_list_id => public_lists.id)
#
require 'rails_helper'

RSpec.describe BookPublicList do
  subject { build(:book_public_list) }

  describe 'associations' do
    it { is_expected.to belong_to(:book).class_name(Book.name).required }
    it { is_expected.to belong_to(:public_list).class_name(PublicList.name).required }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:book_public_list, book: create(:book), public_list: create(:public_list))).to be_valid
    end

    it 'validates uniqueness of book_id and public_list_id combination' do
      book = create(:book)
      public_list = create(:public_list)
      create(:book_public_list, book: book, public_list: public_list)
      duplicate = build(:book_public_list, book: book, public_list: public_list)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:book_id]).to include('has already been taken')
    end
  end
end
