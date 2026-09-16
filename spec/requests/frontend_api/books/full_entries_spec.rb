require 'rails_helper'

RSpec.describe '/api/books/full_entries' do
  describe 'GET /:id' do
    subject(:send_request) { get "/api/books/full_entries/#{book.id}.json", headers: authorization_header }

    let(:book) do
      create(
        :book,
        external_links: external_links,
        genres: book_genres,
        literary_form: 'novel',
        series: series,
        tags: tags
      )
    end
    let!(:description) { create(:description, owner: book, text: 'A book summary.') }
    let(:tags) { create_list(:tag, 2) }
    let(:series) { create_list(:series, 2) }
    let(:wikipedia_link) do
      build(:external_link, external_resource: ExternalResources::WIKIPEDIA,
                            url: 'https://en.wikipedia.org/wiki/Book')
    end
    let(:wikidata_link) do
      build(:external_link, external_resource: ExternalResources::WIKIDATA,
                            url: 'https://www.wikidata.org/wiki/Q1')
    end
    let(:other_links) { build_list(:external_link, 2) }
    let(:external_links) { [wikipedia_link, wikidata_link] + other_links }
    let(:frontend_external_links) { [wikipedia_link] + other_links }
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
        summary: description.text,
        external_links: frontend_external_links.map { |link|
          { external_resource: link.external_resource, url: link.url }
        },
        public_lists: expected_public_lists
      )
    end
  end
end
