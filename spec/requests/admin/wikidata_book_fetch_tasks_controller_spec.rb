require 'rails_helper'

RSpec.describe Admin::WikidataBookFetchTasksController do
  let(:author) { create(:author, fullname: 'Ken MacLeod') }
  let(:genre) { create(:genre, name: 'science fiction') }
  let(:series) { create(:series, name: 'Engines of Light') }
  let(:book) { create(:book, title: 'The Cassini Division', year_published: 1998, authors: [author]) }
  let!(:external_identity) do
    create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q7721452')
  end
  let(:fetched_data) do
    {
      'statements' => {
        'P50' => [
          { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q457608' } }
        ],
        'P577' => [
          {
            'rank' => 'normal',
            'value' => {
              'type' => 'value',
              'content' => { 'time' => '+1998-00-00T00:00:00Z', 'precision' => 9 }
            }
          }
        ],
        'P136' => [
          { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q24925' } }
        ],
        'P179' => [
          { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q123456' } }
        ],
        'P648' => [
          { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'OL42413123W' } }
        ]
      },
      'sitelinks' => {
        'enwiki' => {
          'title' => 'The Cassini Division',
          'url' => 'https://en.wikipedia.org/wiki/The_Cassini_Division'
        },
        'enwikiquote' => {
          'title' => 'The Cassini Division',
          'url' => 'https://en.wikiquote.org/wiki/The_Cassini_Division'
        }
      }
    }
  end
  let!(:task) do
    create(
      :wikidata_fetch_task,
      target: external_identity,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  before do
    create(:wikidata_lookup_entity, qid: 'Q457608', label: 'Ken MacLeod')
    create(:wikidata_lookup_entity, qid: 'Q24925', label: 'science fiction')
    create(:wikidata_lookup_entity, qid: 'Q123456', label: 'Engines of Light')
  end

  describe 'GET /admin/wikidata_book_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_wikidata_book_fetch_task_path(task), headers: authorization_header }

    it 'renders the apply form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:book)).to eq(book)
      expect(response.body).to include('Wikidata fetch results')
      expect(response.body).to include('Year')
      expect(response.body).to include('1998')
      expect(response.body).to include('Q457608')
      expect(response.body).to include('https://www.wikidata.org/wiki/Q457608')
      expect(response.body).to include('add to the author')
      expect(response.body).to include('Q24925')
      expect(response.body).to include('add to the genre')
      expect(response.body).to include('Q123456')
      expect(response.body).to include('add to the series')
      expect(response.body).to include('open_library')
      expect(response.body).to include('OL42413123W')
      expect(response.body).to include('en.wikipedia.org')
      expect(response.body).to include('b-external-link-icon')
      expect(response.body).to include('en.wikiquote.org')
      expect(assigns(:year)).to eq(1998)
      expect(assigns(:wikipedia_sitelinks).size).to eq(1)
      expect(assigns(:other_sitelinks)).to eq(
        [
          {
            'external_resource' => 'en.wikiquote.org',
            'url' => 'https://en.wikiquote.org/wiki/The_Cassini_Division'
          }
        ]
      )
    end

    context 'when the selected wikipedia url already exists on the book' do
      before do
        create(
          :external_link,
          owner: book,
          external_resource: 'wikipedia',
          url: 'https://en.wikipedia.org/wiki/The_Cassini_Division'
        )
      end

      it 'disables the wikipedia add button' do
        send_request
        expect(response.body).to include('disabled')
      end
    end
  end

  describe 'POST /admin/wikidata_book_fetch_tasks/:id/apply_year' do
    let(:send_request) do
      post apply_year_admin_wikidata_book_fetch_task_path(task),
           params: { year: 1999 },
           headers: authorization_header
    end

    it 'updates the year and reloads the apply form' do
      send_request
      expect(book.reload.year_published).to eq(1999)
      expect(response).to redirect_to(edit_admin_wikidata_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('Publication year updated.')
    end
  end

  describe 'POST /admin/wikidata_book_fetch_tasks/:id/add_identity' do
    let(:send_request) do
      post add_identity_admin_wikidata_book_fetch_task_path(task),
           params: { external_resource: 'open_library', external_id: 'OL42413123W' },
           headers: authorization_header
    end

    it 'creates an identity and reloads the apply form' do
      expect { send_request }.to change(book.external_identities, :count).by(1)
      expect(response).to redirect_to(edit_admin_wikidata_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('External identity added.')
    end
  end

  describe 'POST /admin/wikidata_book_fetch_tasks/:id/add_author_identity' do
    let(:send_request) do
      post add_author_identity_admin_wikidata_book_fetch_task_path(task),
           params: { entity_id: 'Q457608', author_id: author.id },
           headers: authorization_header
    end

    it 'creates an author identity and reloads the apply form' do
      expect { send_request }.to change(author.external_identities, :count).by(1)
      expect(response).to redirect_to(edit_admin_wikidata_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('Wikidata author identity added.')
    end
  end

  describe 'POST /admin/wikidata_book_fetch_tasks/:id/add_genre_identity' do
    let(:send_request) do
      post add_genre_identity_admin_wikidata_book_fetch_task_path(task),
           params: { entity_id: 'Q24925', genre_id: genre.id },
           headers: authorization_header
    end

    it 'creates a genre identity, links the genre to the book, and reloads the apply form' do
      expect { send_request }.to change(genre.external_identities, :count).by(1)
        .and change { book.genres.count }.by(1)
      expect(response).to redirect_to(edit_admin_wikidata_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('Wikidata genre identity added.')
    end

    context 'with a free-text genre name' do
      let(:send_request) do
        post add_genre_identity_admin_wikidata_book_fetch_task_path(task),
             params: { entity_id: 'Q24925', genre_query: 'Hard Science Fiction' },
             headers: authorization_header
      end

      it 'creates the genre, identity, and book link' do
        expect { send_request }.to change(Genre, :count).by(1)
          .and change { book.genres.count }.by(1)
        created = Admin::Genre.find_by!(name: 'hard_science_fiction')
        expect(created.external_identities.wikidata.find_by!(external_id: 'Q24925')).to be_present
      end
    end
  end

  describe 'POST /admin/wikidata_book_fetch_tasks/:id/add_series_identity' do
    let(:send_request) do
      post add_series_identity_admin_wikidata_book_fetch_task_path(task),
           params: { entity_id: 'Q123456', series_id: series.id },
           headers: authorization_header
    end

    it 'creates a series identity, links the series to the book, and reloads the apply form' do
      expect { send_request }.to change(series.external_identities, :count).by(1)
        .and change { book.book_series.count }.by(1)
      expect(response).to redirect_to(edit_admin_wikidata_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('Wikidata series identity added.')
    end

    context 'with a free-text series name' do
      let(:send_request) do
        post add_series_identity_admin_wikidata_book_fetch_task_path(task),
             params: { entity_id: 'Q123456', series_query: 'Fall Revolution' },
             headers: authorization_header
      end

      it 'creates the series, identity, and book link' do
        expect { send_request }.to change(Series, :count).by(1)
          .and change { book.book_series.count }.by(1)
        created = Admin::Series.find_by!(name: 'Fall Revolution')
        expect(created.external_identities.wikidata.find_by!(external_id: 'Q123456')).to be_present
      end
    end
  end

  describe 'POST /admin/wikidata_book_fetch_tasks/:id/add_wikipedia_link' do
    let(:send_request) do
      post add_wikipedia_link_admin_wikidata_book_fetch_task_path(task),
           params: { url: 'https://en.wikipedia.org/wiki/The_Cassini_Division' },
           headers: authorization_header
    end

    it 'creates a wikipedia link and reloads the apply form' do
      expect { send_request }.to change(book.external_links, :count).by(1)
      link = book.external_links.find_by!(url: 'https://en.wikipedia.org/wiki/The_Cassini_Division')
      expect(link.external_resource).to eq('wikipedia')
      expect(response).to redirect_to(edit_admin_wikidata_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('Wikipedia link added.')
    end
  end

  describe 'POST /admin/wikidata_book_fetch_tasks/:id/add_link' do
    let(:send_request) do
      post add_link_admin_wikidata_book_fetch_task_path(task),
           params: {
             url: 'https://en.wikiquote.org/wiki/The_Cassini_Division',
             external_resource: 'en.wikiquote.org'
           },
           headers: authorization_header
    end

    it 'creates an external link and reloads the apply form' do
      expect { send_request }.to change(book.external_links, :count).by(1)
      expect(response).to redirect_to(edit_admin_wikidata_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('External link added.')
    end
  end
end
