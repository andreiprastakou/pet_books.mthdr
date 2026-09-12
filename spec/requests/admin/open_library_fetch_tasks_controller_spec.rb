require 'rails_helper'

RSpec.describe Admin::OpenLibraryFetchTasksController do
  let(:book) { create(:book, title: 'The Sea Serpent', summary: 'Existing summary') }
  let(:external_identity) do
    create(:external_identity, owner: book, external_resource: :open_library, identificator: 'OL1099866W')
  end
  let(:fetched_data) do
    {
      'title' => 'The sea serpent',
      'description' => { 'type' => '/type/text', 'value' => 'A Verne novel.' },
      'identifiers' => {
        'wikidata' => ['Q137179018'],
        'goodreads' => ['87596585'],
        'isfdb' => ['3537436']
      }
    }
  end
  let(:task) do
    create(
      :open_library_fetch_task,
      target: external_identity,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  describe 'GET /admin/open_library_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_open_library_fetch_task_path(task), headers: authorization_header }

    it 'renders the selection form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:book)).to eq(book)
      expect(response.body).to include('Open Library fetch results')
      expect(response.body).to include('Current summary:')
      expect(response.body).to include('Existing summary')
      expect(response.body).to include('A Verne novel.')
      expect(response.body).to include('wikidata')
      expect(response.body).to include('https://www.wikidata.org/wiki/Q137179018')
      expect(response.body).to include('add to the book')
      expect(response.body).to include('apply summary')
      expect(assigns(:identifiers)).to eq(
        [
          ['wikidata', 'Q137179018'],
          ['goodreads', '87596585']
        ]
      )
    end

    context 'when an identifier is already present on the book' do
      before do
        create(:external_identity, owner: book, external_resource: :wikidata, identificator: 'Q137179018')
      end

      it 'disables the matching add button' do
        send_request
        expect(response.body).to include('disabled')
      end
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/add_identity' do
    let(:send_request) do
      post add_identity_admin_open_library_fetch_task_path(task),
           params: { external_resource: 'wikidata', identificator: 'Q137179018' },
           headers: authorization_header
    end

    it 'creates an identity and reloads the task page' do
      expect { send_request }.to change(book.external_identities, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(admin_data_fetch_task_path(task))
      expect(flash[:notice]).to eq('External identity added.')
    end
  end

  describe 'POST /admin/open_library_fetch_tasks/:id/apply_summary' do
    let(:send_request) do
      post apply_summary_admin_open_library_fetch_task_path(task),
           params: { summary: 'A Verne novel.' },
           headers: authorization_header
    end

    it 'updates the book summary and reloads the task page' do
      send_request
      expect(book.reload.summary).to eq('A Verne novel.')
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(admin_data_fetch_task_path(task))
      expect(flash[:notice]).to eq('Book summary updated.')
    end
  end
end
