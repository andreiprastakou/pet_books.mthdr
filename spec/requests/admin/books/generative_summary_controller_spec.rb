require 'rails_helper'

RSpec.describe Admin::Books::GenerativeSummaryController do
  describe 'POST /admin/books/:id/generative_summary' do
    let(:send_request) { post admin_book_generative_summary_path(book), headers: authorization_header }
    let(:book) { create(:book) }
    let(:task) { build_stubbed(:book_summary_task, target: book) }

    before do
      allow(Admin::BookSummaryTask).to receive(:setup).with(book).and_return(task)
      allow(task).to receive(:perform)
    end

    it 'creates a task and redirects to the show page' do
      expect { send_request }.to have_enqueued_job(Admin::DataFetchJob).with(task.id)
      expect(response).to redirect_to(admin_book_path(book))
    end
  end

  describe 'GET /admin/books/:id/generative_summary' do
    let(:send_request) { get admin_book_generative_summary_path(book, task_id: task.id), headers: authorization_header }
    let(:book) { create(:book) }
    let(:task) { create(:book_summary_task, target: book, fetched_data: summaries, status: :fetched) }
    let(:summaries) do
      [
        { 'summary' => 'SUMMARY_A', 'themes' => 'theme_a', 'genre' => 'genre_a', 'src' => 'src_a' },
        { 'summary' => 'SUMMARY_B', 'themes' => 'theme_b', 'genre' => 'genre_b', 'src' => 'src_b' }
      ]
    end

    it 'renders the show template' do
      send_request
      expect(response).to render_template('admin/books/generative_summary/show')
      aggregate_failures do
        expect(assigns(:book)).to eq(book)
        expect(assigns(:form)).to be_a(Forms::BookForm)
        expect(assigns(:summaries)).to eq(task.fetched_data.map(&:symbolize_keys))
        expect(assigns(:all_themes)).to match_array(%w[theme_a theme_b])
      end
    end

    context 'when the task is not in fetched state' do
      let(:task) { create(:book_summary_task, target: book, status: :failed) }

      it 'redirects to book with an error message' do
        send_request
        expect(response).to redirect_to(admin_data_fetch_task_path(task))
      end
    end
  end

  describe 'PUT /admin/books/:id/generative_summary/reject' do
    let(:send_request) do
      put reject_admin_book_generative_summary_path(book, task_id: task.id), headers: authorization_header
    end
    let(:book) { create(:book) }
    let(:task) { create(:book_summary_task, target: book, status: :fetched) }

    it 'rejects the task and redirects to the feed page' do
      send_request
      expect(task.reload).to be_rejected
      expect(response).to redirect_to(admin_feed_path)
    end

    context 'when there are more fetched tasks' do
      let(:task_b) { create(:book_summary_task, target: book, status: :fetched) }

      before { task_b }

      it 'redirects to its form' do
        send_request
        expect(response).to redirect_to(admin_book_generative_summary_path(book, task_id: task_b.id))
      end
    end
  end

  describe 'PUT /admin/books/:id/generative_summary/verify' do
    let(:send_request) do
      put verify_admin_book_generative_summary_path(book, task_id: task.id), headers: authorization_header
    end
    let(:book) { create(:book) }
    let(:task) { create(:book_summary_task, target: book, status: :fetched) }

    it 'verifies the task and returns OK' do
      send_request
      expect(task.reload).to be_verified
      expect(response).to be_ok
    end
  end
end
