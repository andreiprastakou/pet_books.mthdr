require 'rails_helper'

RSpec.describe Admin::WikidataBookSearchTasksController do
  let(:book) { create(:book, title: 'In the Slopes') }
  let(:task) do
    create(
      :wikidata_search_task,
      target: book,
      status: :fetched,
      fetched_data: [
        {
          'id' => 'Q74287',
          'display-label' => { 'language' => 'en', 'value' => 'In the Slopes' },
          'description' => { 'language' => 'en', 'value' => 'book by author' }
        }
      ]
    )
  end

  describe 'GET /admin/data_fetch_tasks/:id' do
    let(:send_request) { get admin_data_fetch_task_path(task), headers: authorization_header }

    it 'renders usable values with an add-to-book form' do
      send_request
      expect(response).to be_successful
      expect(response.body).to include('Wikidata search results')
      expect(response.body).to include('Q74287')
      expect(response.body).to include('https://www.wikidata.org/wiki/Q74287')
      expect(response.body).to include('add to the book')
      expect(response.body).not_to include('disabled')
    end

    context 'when the book already has that Wikidata identity' do
      before do
        create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q74287')
      end

      it 'disables the add button' do
        send_request
        expect(response).to be_successful
        expect(response.body).to include('disabled')
      end
    end
  end

  describe 'POST /admin/wikidata_book_search_tasks/:id/add_work_identity' do
    let(:send_request) do
      post add_work_identity_admin_wikidata_book_search_task_path(task),
           params: { entity_id: 'Q74287' },
           headers: authorization_header
    end

    it 'creates a work identity and reloads the task page' do
      expect { send_request }.to change(book.external_identities, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(admin_data_fetch_task_path(task))
      expect(flash[:notice]).to eq('Wikidata work identity added.')
    end

    context 'when entity id is invalid' do
      let(:send_request) do
        post add_work_identity_admin_wikidata_book_search_task_path(task),
             params: { entity_id: 'not-a-qid' },
             headers: authorization_header
      end

      it 'redirects back with an error' do
        expect { send_request }.not_to change(book.external_identities, :count)
        expect(response).to redirect_to(admin_data_fetch_task_path(task))
        expect(flash[:error]).to eq('Invalid Wikidata entity id')
      end
    end
  end
end
