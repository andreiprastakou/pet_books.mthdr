require 'rails_helper'

RSpec.describe Admin::DataFetchTasksController, type: :request do
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
  end
end
