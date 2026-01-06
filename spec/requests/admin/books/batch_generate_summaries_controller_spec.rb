require 'rails_helper'

RSpec.describe Admin::Books::BatchGenerateSummariesController do
  describe 'POST /admin/books/batch_generate_summaries' do
    let(:send_request) do
      post admin_books_batch_generate_summaries_path, params: params, headers: authorization_header
    end
    let(:params) do
      {
        book_ids: [book_needs_fetch.id, book_already_filled.id, book_short_form.id]
      }
    end

    let(:book_needs_fetch) do
      create(:book, data_filled: false, literary_form: 'novel')
    end
    let(:book_already_filled) do
      create(:book, data_filled: true, literary_form: 'novel')
    end
    let(:book_short_form) do
      create(:book, data_filled: false, literary_form: 'short')
    end

    before do
      allow(Admin::DataFetchJob).to receive(:perform_later)
    end

    it 'creates tasks only for books that need data fetch' do
      expect { send_request }.to change(Admin::BookSummaryTask, :count).by(1)
      new_task = Admin::BookSummaryTask.last
      expect(new_task.target).to eq(book_needs_fetch)
      expect(Admin::DataFetchJob).to have_received(:perform_later).with(new_task.id)
    end

    it 'redirects back to admin books path with success notice' do
      send_request
      expect(response).to redirect_to(admin_books_path)
      expect(flash[:notice]).to eq(I18n.t('notices.admin.books_batch_generate_summaries.success'))
    end

    context 'when no books need data fetch' do
      let(:params) do
        {
          book_ids: [book_already_filled.id, book_short_form.id]
        }
      end

      it 'redirects with a warning' do
        send_request
        expect(response).to redirect_to(admin_books_path)
        expect(flash[:notice]).to eq(I18n.t('notices.admin.books_batch_generate_summaries.nothing_to_fetch'))
      end
    end
  end
end
