require 'rails_helper'

RSpec.describe Admin::WikipediaBookFetchTasksController do
  let(:book) { create(:book, title: 'Medea') }
  let!(:description) do
    create(
      :description,
      owner: book,
      text: 'Existing summary',
      source_label: 'Old SRC',
      source_type: 'Admin::Tasks::WikipediaBookFetch',
      source_id: 0
    )
  end
  let(:fetched_data) do
    {
      'batchcomplete' => true,
      'query' => {
        'pages' => [
          {
            'pageid' => 28_103_851,
            'title' => 'Medea (Seneca)',
            'extract' => 'Medea is a fabula crepidata written by Seneca the Younger.'
          }
        ]
      }
    }
  end
  let!(:task) do
    create(
      :wikipedia_book_fetch_task,
      target: book,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  describe 'GET /admin/wikipedia_book_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_wikipedia_book_fetch_task_path(task), headers: authorization_header }

    it 'renders the apply form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:book)).to eq(book)
      expect(response.body).to include('Wikipedia fetch results')
      expect(response.body).to include(description.text)
      expect(response.body).to include('fabula crepidata')
      expect(assigns(:fetched_data)['description']).to eq(
        'Medea is a fabula crepidata written by Seneca the Younger.'
      )
    end
  end

  describe 'POST /admin/wikipedia_book_fetch_tasks/:id/apply_summary' do
    let(:send_request) do
      post apply_summary_admin_wikipedia_book_fetch_task_path(task),
           params: { text: 'Medea is a fabula crepidata written by Seneca the Younger.' },
           headers: authorization_header
    end

    it 'updates the book description and reloads the apply form' do
      send_request
      book.reload
      applied = book.description_for_source(task)
      expect(applied.text).to eq('Medea is a fabula crepidata written by Seneca the Younger.')
      expect(applied.source_label).to be_nil
      expect(applied.source_type).to eq(task.class.name)
      expect(applied.source_id).to eq(task.id)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_wikipedia_book_fetch_task_path(task))
      expect(flash[:notice]).to eq('Book summary updated.')
    end
  end
end
