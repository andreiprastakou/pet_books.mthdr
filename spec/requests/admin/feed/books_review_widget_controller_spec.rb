require 'rails_helper'

RSpec.describe Admin::Feed::BooksReviewWidgetController do
  describe 'GET /admin/feed/books_review_widget' do
    let(:send_request) { get admin_feed_books_review_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/books_review_widget/show'
    end

    describe 'rendered data' do
      let(:books) { create_list(:book, 6) + create_list(:book, 3, data_filled: true) }
      let(:summaries) do
        [
          create(:book_summary_task, target: books[3], status: :requested),
          create(:book_summary_task, target: books[4], status: :fetched),
          create(:book_summary_task, target: books[5], status: :verified)
        ]
      end

      before { summaries }

      it 'contains books to review and summaries to verify' do
        send_request
        expect(assigns(:books_to_fill)).to match_array(books[0..2])
        expect(assigns(:summaries_to_verify)).to match_array(summaries[1..1])
      end
    end
  end

  describe 'POST /admin/feed/books_review_widget/request_summary' do
    let(:send_request) do
      post request_summary_admin_feed_books_review_widget_path(book_id: book.id), headers: authorization_header
    end
    let(:book) { create(:book) }
    let(:task) { build_stubbed(:book_summary_task, target: book) }

    before { allow(Admin::BookSummaryTask).to receive(:setup).with(book).and_return(task) }

    it 'creates a task and redirects to the show page' do
      expect { send_request }.to have_enqueued_job(Admin::DataFetchJob).with(task.id)
      expect(response).to render_template 'admin/feed/books_review_widget/show'
    end
  end
end
