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
    let!(:description) do
      create(
        :description,
        owner: book,
        text: 'A book summary.',
        source_label: 'AI: Claude'
      )
    end
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
        read: false,
        pinned: false,
        original_title: book.original_title,
        author_ids: book.author_ids,
        tag_ids: tags.map(&:id),
        series_ids: series.map(&:id),
        year_published: book.year_published,
        format: 'big',
        form_label: 'a fantasy novel',
        collected_work_ids: [],
        summary: description.text,
        summary_source: 'AI: Claude',
        external_links: frontend_external_links.map { |link|
          {
            external_resource: link.external_resource,
            label: ExternalResources.label_for(link.external_resource),
            url: link.url
          }
        },
        public_lists: expected_public_lists
      )
    end

    context 'when the signed-in user has read the book' do
      let(:reader) { create(:user) }

      before do
        sign_in_frontend_user!(reader)
        create(:user_book_read, user: reader, book: book)
      end

      it 'reports the book as read' do
        send_request

        expect(json_response[:read]).to be(true)
      end
    end

    context 'when the signed-in user has pinned the book' do
      let(:reader) { create(:user) }

      before do
        sign_in_frontend_user!(reader)
        create(:user_pin, user: reader, entity: book)
      end

      it 'reports the book as pinned' do
        send_request

        expect(json_response[:pinned]).to be(true)
      end
    end

    context 'when the primary description has no source_label but an Open Library source' do
      let!(:description) do
        create(
          :description,
          owner: book,
          text: 'A book summary.',
          source_type: 'Admin::Tasks::OpenLibraryBookFetch',
          source_id: 1
        )
      end

      it 'returns the open_library external resource as summary_source' do
        send_request

        expect(response).to be_successful
        expect(json_response[:summary_source]).to eq('Open Library')
      end
    end

    context 'when the book collects other works' do
      let(:older_work) { create(:book, title: 'Older Work', year_published: 1990) }
      let(:newer_work) { create(:book, title: 'Newer Work', year_published: 2001) }

      before do
        book.update!(literary_form: 'collection')
        create(:book_collection, collection: book, book: older_work)
        create(:book_collection, collection: book, book: newer_work)
      end

      it 'returns collected work ids newest first' do
        send_request

        expect(json_response[:format]).to eq('collection')
        expect(json_response[:collected_work_ids]).to eq([newer_work.id, older_work.id])
      end
    end
  end
end
