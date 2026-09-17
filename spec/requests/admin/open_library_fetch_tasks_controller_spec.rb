require 'rails_helper'

RSpec.describe Admin::OpenLibraryFetchTasksController do
  let(:author) { create(:author, fullname: 'Jules Verne') }
  let(:genre) { create(:genre, name: 'adventure') }
  let(:series) { create(:series, name: 'Voyages Extraordinaires') }
  let(:book) { create(:book, title: 'The Sea Serpent', authors: [author]) }
  let!(:description) do
    create(
      :description,
      owner: book,
      text: 'Existing summary',
      source_label: 'Old SRC',
      source_type: 'Admin::Tasks::OpenLibraryBookFetch',
      source_id: 0
    )
  end
  let!(:external_identity) do
    create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL1099866W')
  end
  let(:fetched_data) do
    {
      'title' => 'The sea serpent',
      'description' => { 'type' => '/type/text', 'value' => 'A Verne novel.' },
      'authors' => [{ 'author' => { 'key' => '/authors/OL113611A' } }],
      'genres' => ['/tags/OL180T'],
      'series' => [{ 'series' => { 'key' => '/series/OL123S' } }],
      'identifiers' => {
        'wikidata' => ['Q137179018'],
        'goodreads' => ['87596585'],
        'isfdb' => ['3537436']
      },
      'links' => [
        { 'title' => 'Wikipedia', 'url' => 'https://en.wikipedia.org/wiki/The_Sea_Serpent' }
      ]
    }
  end
  let!(:task) do
    create(
      :open_library_fetch_task,
      target: external_identity,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  before do
    create(:book_genre, book: book, genre: genre)
    create(:book_series, book: book, series: series)
  end

  describe 'GET /admin/open_library_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_open_library_fetch_task_path(task), headers: authorization_header }

    it 'renders the selection form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:book)).to eq(book)
      expect(response.body).to include('Open Library fetch results')
      expect(response.body).to include('Current description:')
      expect(response.body).to include('Existing summary')
      expect(response.body).to include('Old SRC')
      expect(response.body).to include('A Verne novel.')
      expect(response.body).to include('OL113611A')
      expect(response.body).to include('https://openlibrary.org/authors/OL113611A')
      expect(response.body).to include('add to the author')
      expect(response.body).to include('/tags/OL180T')
      expect(response.body).to include('https://openlibrary.org/tags/OL180T')
      expect(response.body).to include('add to the genre')
      expect(response.body).to include('/series/OL123S')
      expect(response.body).to include('https://openlibrary.org/series/OL123S')
      expect(response.body).to include('add to the series')
      expect(response.body).to include('wikidata')
      expect(response.body).to include('https://www.wikidata.org/wiki/Q137179018')
      expect(response.body).to include('value="add"')
      expect(response.body).to include('en.wikipedia.org')
      expect(response.body).to include('b-external-link-icon')
      expect(assigns(:fetched_data)['identifiers']).to eq(
        [
          { 'external_resource' => 'wikidata', 'external_id' => 'Q137179018' },
          { 'external_resource' => 'goodreads', 'external_id' => '87596585' }
        ]
      )
      expect(assigns(:fetched_data)['description']).to eq('A Verne novel.')
      expect(assigns(:links)).to eq(
        [
          {
            'external_resource' => 'en.wikipedia.org',
            'url' => 'https://en.wikipedia.org/wiki/The_Sea_Serpent'
          }
        ]
      )
    end

    context 'when an identifier is already present on the book' do
      before do
        create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q137179018')
      end

      it 'disables the matching add button' do
        send_request
        expect(response.body).to include('disabled')
      end
    end

    context 'when the book already has a task description' do
      before do
        description.update!(
          text: 'A Verne novel.',
          source_type: task.class.name,
          source_id: task.id,
          source_label: nil
        )
      end

      it 'shows an update button for the description' do
        send_request
        expect(response.body).to include('value="update"')
      end
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/add_identity' do
    let(:send_request) do
      post add_identity_admin_open_library_fetch_task_path(task),
           params: { external_resource: 'wikidata', external_id: 'Q137179018' },
           headers: authorization_header
    end

    it 'creates an identity and reloads the apply form' do
      expect { send_request }.to change(book.external_identities, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_open_library_fetch_task_path(task))
      expect(flash[:notice]).to eq('External identity added.')
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/add_author_identity' do
    let(:send_request) do
      post add_author_identity_admin_open_library_fetch_task_path(task),
           params: { author_key: 'OL113611A', author_id: author.id },
           headers: authorization_header
    end

    it 'creates an author identity and reloads the apply form' do
      expect { send_request }.to change(author.external_identities, :count).by(1)
      expect(response).to redirect_to(edit_admin_open_library_fetch_task_path(task))
      expect(flash[:notice]).to eq('Open Library author identity added.')
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/add_genre_identity' do
    let(:send_request) do
      post add_genre_identity_admin_open_library_fetch_task_path(task),
           params: { genre_key: '/tags/OL180T', genre_id: genre.id },
           headers: authorization_header
    end

    it 'creates a genre identity and reloads the apply form' do
      expect { send_request }.to change(genre.external_identities, :count).by(1)
      expect(response).to redirect_to(edit_admin_open_library_fetch_task_path(task))
      expect(flash[:notice]).to eq('Open Library genre identity added.')
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/add_series_identity' do
    let(:send_request) do
      post add_series_identity_admin_open_library_fetch_task_path(task),
           params: { series_key: '/series/OL123S', series_id: series.id },
           headers: authorization_header
    end

    it 'creates a series identity and reloads the apply form' do
      expect { send_request }.to change(series.external_identities, :count).by(1)
      expect(response).to redirect_to(edit_admin_open_library_fetch_task_path(task))
      expect(flash[:notice]).to eq('Open Library series identity added.')
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/apply_summary' do
    let(:send_request) do
      post apply_summary_admin_open_library_fetch_task_path(task),
           params: { text: 'A Verne novel.' },
           headers: authorization_header
    end

    it 'updates the book description and reloads the apply form' do
      send_request
      book.reload
      applied = book.description_for_source(task)
      expect(applied.text).to eq('A Verne novel.')
      expect(applied.source_label).to be_nil
      expect(applied.source_type).to eq(task.class.name)
      expect(applied.source_id).to eq(task.id)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_open_library_fetch_task_path(task))
      expect(flash[:notice]).to eq('Book summary updated.')
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/add_link' do
    let(:send_request) do
      post add_link_admin_open_library_fetch_task_path(task),
           params: {
             url: 'https://en.wikipedia.org/wiki/The_Sea_Serpent',
             external_resource: 'en.wikipedia.org'
           },
           headers: authorization_header
    end

    it 'creates an external link and reloads the apply form' do
      expect { send_request }.to change(book.external_links, :count).by(1)
      expect(response).to redirect_to(edit_admin_open_library_fetch_task_path(task))
      expect(flash[:notice]).to eq('External link added.')
    end

    context 'when the link already exists' do
      before do
        create(
          :external_link,
          owner: book,
          external_resource: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/The_Sea_Serpent'
        )
      end

      it 'updates the label' do
        expect { send_request }.not_to change(book.external_links, :count)
        expect(book.external_links.find_by!(url: 'https://en.wikipedia.org/wiki/The_Sea_Serpent').external_resource)
          .to eq('en.wikipedia.org')
        expect(flash[:notice]).to eq('External link label updated.')
      end
    end
  end
end
