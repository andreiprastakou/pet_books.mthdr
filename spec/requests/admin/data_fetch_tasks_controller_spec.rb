require 'rails_helper'

RSpec.describe Admin::DataFetchTasksController do
  describe 'GET /admin/data_fetch_tasks' do
    let(:send_request) { get admin_data_fetch_tasks_path, headers: authorization_header }
    let(:tasks) { create_list(:book_summary_task, 3) }

    before { tasks }

    it 'returns a successful response' do
      send_request
      expect(response).to be_successful
      expect(assigns(:tasks)).to match_array(tasks)
    end
  end

  describe 'GET /admin/data_fetch_tasks/:id' do
    let(:send_request) { get admin_data_fetch_task_path(task), headers: authorization_header }
    let(:task) { create(:book_summary_task) }

    it 'returns a successful response' do
      send_request
      expect(response).to be_successful
      expect(assigns(:task)).to eq(task)
    end

    context 'with an OpenLibrarySearchTask' do
      let(:task) { create(:open_library_search_task, status: :fetched, fetched_data: []) }

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_open_library_search_task')
      end
    end

    context 'with an OpenLibraryFetchTask' do
      let(:task) { create(:open_library_fetch_task, status: :fetched, fetched_data: { 'title' => 'X' }) }

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_open_library_fetch_task')
      end
    end

    context 'with a WikidataFetchTask' do
      let(:task) do
        create(
          :wikidata_fetch_task,
          status: :fetched,
          fetched_data: { 'id' => 'Q74287', 'labels' => { 'en' => 'The Hobbit' } }
        )
      end

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikidata_fetch_task')
      end
    end

    context 'when the task is fetched' do
      let(:task) { create(:open_library_search_task, status: :fetched, fetched_data: []) }

      it 'renders verify and reject buttons' do
        send_request
        expect(response.body).to include('mark as verified')
        expect(response.body).to include('mark as rejected')
      end
    end
  end

  describe 'PUT /admin/data_fetch_tasks/:id/verify' do
    let(:task) { create(:open_library_search_task, status: :fetched) }
    let(:send_request) { put verify_admin_data_fetch_task_path(task), headers: authorization_header }

    it 'marks the task verified and redirects home' do
      send_request
      expect(task.reload.status).to eq('verified')
      expect(response).to redirect_to(admin_root_path)
      expect(flash[:notice]).to eq("Task ID=#{task.id} marked as verified")
    end
  end

  describe 'PUT /admin/data_fetch_tasks/:id/reject' do
    let(:task) { create(:open_library_search_task, status: :fetched) }
    let(:send_request) { put reject_admin_data_fetch_task_path(task), headers: authorization_header }

    it 'marks the task rejected and redirects home' do
      send_request
      expect(task.reload.status).to eq('rejected')
      expect(response).to redirect_to(admin_root_path)
      expect(flash[:notice]).to eq("Task ID=#{task.id} marked as rejected")
    end
  end
end
