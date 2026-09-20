require 'rails_helper'

RSpec.describe Admin::Feed::WikipediaUpdatesWidgetController do
  describe 'GET /admin/feed/wikipedia_updates_widget' do
    let(:send_request) { get admin_feed_wikipedia_updates_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/wikipedia_updates_widget/show'
    end

    describe 'rendered data' do
      let!(:book_fetch_tasks) do
        [
          create(:wikipedia_book_fetch_task, status: :requested),
          create(:wikipedia_book_fetch_task, status: :fetched),
          create(:wikipedia_book_fetch_task, status: :verified)
        ]
      end
      let!(:author_fetch_tasks) do
        [
          create(:wikipedia_author_fetch_task, status: :requested),
          create(:wikipedia_author_fetch_task, status: :fetched),
          create(:wikipedia_author_fetch_task, status: :verified)
        ]
      end

      it 'contains fetched tasks waiting for review' do
        send_request
        expect(assigns(:book_fetches)).to eq([book_fetch_tasks[1]])
        expect(assigns(:book_fetches_count)).to eq(1)
        expect(assigns(:author_fetches)).to eq([author_fetch_tasks[1]])
        expect(assigns(:author_fetches_count)).to eq(1)
      end

      it 'renders column headers with totals and filter links' do
        send_request
        expect(response.body).to include('Wikipedia updates for review')
        expect(response.body).to include('Book fetches')
        expect(response.body).to include('Author fetches')
        expect(response.body).to include('1 total')

        expect(response.body).to include(
          ERB::Util.html_escape(
            admin_data_fetch_tasks_path(type: Admin::Tasks::WikipediaBookFetch.name, status: :fetched, commit: 'Filter')
          )
        )
        expect(response.body).to include(
          ERB::Util.html_escape(
            admin_data_fetch_tasks_path(type: Admin::Tasks::WikipediaAuthorFetch.name, status: :fetched, commit: 'Filter')
          )
        )

        book = book_fetch_tasks[1].book
        expect(response.body).to include("#{book.title} (#{book.year_published}) by #{book.author_names_label}")
        expect(response.body).to include(author_fetch_tasks[1].author.fullname)
      end
    end
  end
end
