require 'rails_helper'

RSpec.describe Admin::WikipediaAuthorFetchTasksController do
  let(:author) { create(:author, fullname: 'Seneca') }
  let!(:description) do
    create(
      :description,
      owner: author,
      text: 'Existing description',
      source_label: 'Old SRC',
      source_type: 'Admin::Tasks::WikipediaAuthorFetch',
      source_id: 0
    )
  end
  let(:fetched_data) do
    {
      'query' => {
        'pages' => [
          { 'title' => 'Seneca', 'extract' => 'A Roman Stoic philosopher.' }
        ]
      }
    }
  end
  let!(:task) do
    create(
      :wikipedia_author_fetch_task,
      target: author,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  describe 'GET /admin/wikipedia_author_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_wikipedia_author_fetch_task_path(task), headers: authorization_header }

    it 'renders the apply form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:author)).to eq(author)
      expect(response.body).to include('Wikipedia fetch results')
      expect(response.body).to include(description.text)
      expect(response.body).to include('Roman Stoic philosopher')
      expect(assigns(:fetched_data)['description']).to eq('A Roman Stoic philosopher.')
    end
  end

  describe 'POST /admin/wikipedia_author_fetch_tasks/:id/apply_description' do
    let(:send_request) do
      post apply_description_admin_wikipedia_author_fetch_task_path(task),
           params: { text: 'A Roman Stoic philosopher.' },
           headers: authorization_header
    end

    it 'updates the author description and reloads the apply form' do
      send_request
      author.reload
      applied = author.description_for_source(task)
      expect(applied.text).to eq('A Roman Stoic philosopher.')
      expect(applied.source_label).to be_nil
      expect(applied.source_type).to eq(task.class.name)
      expect(applied.source_id).to eq(task.id)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_wikipedia_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('Author description updated.')
    end
  end
end
