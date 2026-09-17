require 'rails_helper'

RSpec.describe Admin::WikidataAuthorSearchTasksController do
  let(:author) { create(:author, fullname: 'Robert Jordan') }
  let(:task) do
    create(
      :wikidata_author_search_task,
      target: author,
      status: :fetched,
      fetched_data: [
        {
          'id' => 'Q892',
          'display-label' => { 'language' => 'en', 'value' => 'Robert Jordan' },
          'description' => { 'language' => 'en', 'value' => 'American writer' }
        }
      ]
    )
  end

  describe 'GET /admin/wikidata_author_search_tasks/:id/edit' do
    let(:send_request) { get edit_admin_wikidata_author_search_task_path(task), headers: authorization_header }

    it 'renders usable values with an add-to-author form' do
      send_request
      expect(response).to be_successful
      expect(response.body).to include('Wikidata author search results')
      expect(response.body).to include('Q892')
      expect(response.body).to include('https://www.wikidata.org/wiki/Q892')
      expect(response.body).to include('add to the author')
      expect(response.body).not_to include('disabled')
    end

    context 'when the author already has that Wikidata identity' do
      before do
        create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
      end

      it 'disables the add button' do
        send_request
        expect(response).to be_successful
        expect(response.body).to include('disabled')
      end
    end
  end

  describe 'POST /admin/wikidata_author_search_tasks/:id/add_author_identity' do
    let(:send_request) do
      post add_author_identity_admin_wikidata_author_search_task_path(task),
           params: { entity_id: 'Q892' },
           headers: authorization_header
    end

    it 'creates an author identity and reloads the apply form' do
      expect { send_request }.to change(author.external_identities, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_wikidata_author_search_task_path(task))
      expect(flash[:notice]).to eq('Wikidata author identity added.')
    end

    context 'when entity id is invalid' do
      let(:send_request) do
        post add_author_identity_admin_wikidata_author_search_task_path(task),
             params: { entity_id: 'not-a-qid' },
             headers: authorization_header
      end

      it 're-renders the apply form with an error' do
        expect { send_request }.not_to change(author.external_identities, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:edit)
        expect(flash[:error]).to eq('Invalid Wikidata entity id')
      end
    end
  end
end
