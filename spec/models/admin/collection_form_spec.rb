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

RSpec.describe Admin::CollectionForm do
  describe '#book_ids=' do
    subject(:call) { form.book_ids = book_ids }

    let(:form) { create(:admin_collection_form, book_collections: initial_book_collections) }
    let(:books) { create_list(:book, 3) }
    let(:initial_book_collections) { [build(:book_collection, book: books[0]), build(:book_collection, book: books[1])] }
    let(:book_ids) { [books[1].id, books[2].id, ""] }

    it 'assigns the books by given ids' do
      form
      expect { call }.not_to change(BookCollection, :count)
      expect(form.book_collections.map(&:book_id)).to eq(books[0..2].map(&:id))
      expect(form.book_collections.map(&:marked_for_destruction?)).to eq([true, false, false])
      expect(form.book_collections.map(&:new_record?)).to eq([false, false, true])
    end
  end
end
