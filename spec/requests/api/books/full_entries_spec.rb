require 'rails_helper'

RSpec.describe '/api/books/full_entries' do
  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/full_entries/#{book.id}.json", headers: authorization_header }

    let(:book) { create(:book, tags: tags) }
    let(:tags) { create_list(:tag, 2) }

    it 'renders the book' do
      book
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(
        id: book.id,
        title: book.title,
        original_title: book.original_title,
        author_id: book.author_ids.first,
        tag_ids: tags.map(&:id),
        year_published: book.year_published,
        cover_thumb_url: nil
      )
    end
  end
end
