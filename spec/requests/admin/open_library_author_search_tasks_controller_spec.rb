require 'rails_helper'

RSpec.describe Admin::OpenLibraryAuthorSearchTasksController do
  let(:author) { create(:author, fullname: 'Robert Jordan') }
  let(:task) do
    create(
      :open_library_author_search_task,
      target: author,
      status: :fetched,
      fetched_data: [
        {
          'key' => 'OL233594A',
          'name' => 'Robert Jordan',
          'birth_date' => '17 October 1948',
          'death_date' => '16 September 2007',
          'type' => 'author',
          'ratings_count' => 845
        }
      ]
    )
  end

  describe 'GET /admin/data_fetch_tasks/:id' do
    let(:send_request) { get admin_data_fetch_task_path(task), headers: authorization_header }

    it 'renders usable values with an add-to-author form' do
      send_request
      expect(response).to be_successful
      expect(response.body).to include('Open Library author search results')
      expect(response.body).to include('OL233594A')
      expect(response.body).to include('https://openlibrary.org/authors/OL233594A')
      expect(response.body).to include('add to the author')
      expect(response.body).not_to include('disabled')
    end

    context 'when the author already has that Open Library identity' do
      before do
        create(:external_identity, owner: author, external_resource: :open_library, external_id: 'OL233594A')
      end

      it 'disables the add button' do
        send_request
        expect(response).to be_successful
        expect(response.body).to include('disabled')
      end
    end
  end

  describe 'POST /admin/open_library_author_search_tasks/:id/add_author_identity' do
    let(:send_request) do
      post add_author_identity_admin_open_library_author_search_task_path(task),
           params: { author_key: 'OL233594A' },
           headers: authorization_header
    end

    it 'creates an author identity and reloads the task page' do
      expect { send_request }.to change(author.external_identities, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(admin_data_fetch_task_path(task))
      expect(flash[:notice]).to eq('Open Library author identity added.')
    end

    context 'when author key is invalid' do
      let(:send_request) do
        post add_author_identity_admin_open_library_author_search_task_path(task),
             params: { author_key: 'not-a-key' },
             headers: authorization_header
      end

      it 'redirects back with an error' do
        expect { send_request }.not_to change(author.external_identities, :count)
        expect(response).to redirect_to(admin_data_fetch_task_path(task))
        expect(flash[:error]).to eq('Invalid Open Library author key')
      end
    end
  end
end
