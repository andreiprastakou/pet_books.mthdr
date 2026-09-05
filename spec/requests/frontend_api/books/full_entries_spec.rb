require 'rails_helper'

RSpec.describe '/api/books/full_entries' do
  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/full_entries/#{book.id}.json", headers: authorization_header }

    let(:book) do
      create(
        :book,
        generic_links: generic_links,
        genres: book_genres,
        literary_form: 'novel',
        series: series,
        summary: 'A book summary.',
        tags: tags,
        wiki_url: 'https://en.wikipedia.org/wiki/Book'
      )
    end
    let(:tags) { create_list(:tag, 2) }
    let(:series) { create_list(:series, 2) }
    let(:generic_links) { build_list(:generic_link, 2) }
    let(:book_genres) { [build(:book_genre, genre: create(:genre, name: 'fantasy'))] }
    let(:list_type_a) { create(:public_list_type, name: 'Alpha Prize') }
    let(:list_type_b) { create(:public_list_type, name: 'Beta Prize') }
    let(:public_list_older) { create(:public_list, public_list_type: list_type_b, year: 2019) }
    let(:public_list_newer_a) { create(:public_list, public_list_type: list_type_a, year: 2021) }
    let(:public_list_newer_b) { create(:public_list, public_list_type: list_type_b, year: 2021) }

    let(:expected_public_lists) do
      [
        {
          public_list_id: public_list_newer_a.id,
          public_list_type_id: list_type_a.id,
          public_list_type_name: 'Alpha Prize',
          public_list_year: 2021,
          book_role: 'winner'
        },
        {
          public_list_id: public_list_newer_b.id,
          public_list_type_id: list_type_b.id,
          public_list_type_name: 'Beta Prize',
          public_list_year: 2021,
          book_role: 'finalist'
        },
        {
          public_list_id: public_list_older.id,
          public_list_type_id: list_type_b.id,
          public_list_type_name: 'Beta Prize',
          public_list_year: 2019,
          book_role: 'nominee'
        }
      ]
    end

    before do
      create(:book_public_list, book: book, public_list: public_list_older, role: 'nominee')
      create(:book_public_list, book: book, public_list: public_list_newer_b, role: 'finalist')
      create(:book_public_list, book: book, public_list: public_list_newer_a, role: 'winner')
    end

    it 'renders the book' do
      send_request

      expect(response).to be_successful
      expect(json_response).to eq(
        id: book.id,
        title: book.title,
        original_title: book.original_title,
        author_ids: book.author_ids,
        tag_ids: tags.map(&:id),
        series_ids: series.map(&:id),
        year_published: book.year_published,
        small: false,
        form_label: 'a fantasy novel',
        summary: book.summary,
        wiki_url: book.wiki_url,
        generic_links: generic_links.map { |link| { name: link.name, url: link.url } },
        public_lists: expected_public_lists
      )
    end
  end
end
