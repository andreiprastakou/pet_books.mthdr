require 'rails_helper'

RSpec.describe Admin::BooksHelper, type: :helper do
  describe '#book_label_for_badges' do
    let(:book) { build(:book, title: 'BOOK_A', year_published: 2020, authors: [author]) }
    let(:author) { create(:author, fullname: 'AUTHOR_A') }

    it 'returns the correct label' do
      expect(helper.book_label_for_badges(book)).to eq(
        "BOOK_A by AUTHOR_A, 2020"
      )
    end
  end
end
