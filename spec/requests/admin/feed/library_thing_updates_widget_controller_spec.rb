require 'rails_helper'

RSpec.describe Admin::Feed::LibraryThingUpdatesWidgetController do
  describe 'GET /admin/feed/library_thing_updates_widget' do
    let(:send_request) { get admin_feed_library_thing_updates_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/library_thing_updates_widget/show'
    end

    describe 'rendered data' do
      let!(:book_search_tasks) do
        [
          create(:library_thing_search_task, status: :requested),
          create(:library_thing_search_task, status: :fetched),
          create(:library_thing_search_task, status: :verified)
        ]
      end

      it 'contains fetched tasks waiting for review' do
        send_request
        expect(assigns(:book_searches)).to eq([book_search_tasks[1]])
        expect(assigns(:book_searches_count)).to eq(1)
      end

      it 'renders column headers with totals and filter links' do
        send_request
        expect(response.body).to include('LibraryThing updates for review')
        expect(response.body).to include('Book searches')
        expect(response.body).to include('1 total')

        expect(response.body).to include(
          ERB::Util.html_escape(
            admin_data_fetch_tasks_path(type: Admin::Tasks::LibraryThingBookSearch.name, status: :fetched, commit: 'Filter')
          )
        )

        book = book_search_tasks[1].book
        expect(response.body).to include("#{book.title} (#{book.year_published}) by #{book.author_names_label}")
      end
    end
  end
end
