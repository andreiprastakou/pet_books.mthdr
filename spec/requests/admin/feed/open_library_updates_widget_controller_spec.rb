require 'rails_helper'

RSpec.describe Admin::Feed::OpenLibraryUpdatesWidgetController do
  describe 'GET /admin/feed/open_library_updates_widget' do
    let(:send_request) { get admin_feed_open_library_updates_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/open_library_updates_widget/show'
    end

    describe 'rendered data' do
      let!(:book_search_tasks) do
        [
          create(:open_library_search_task, status: :requested),
          create(:open_library_search_task, status: :fetched),
          create(:open_library_search_task, status: :verified)
        ]
      end
      let!(:book_fetch_tasks) do
        [
          create(:open_library_fetch_task, status: :requested),
          create(:open_library_fetch_task, status: :fetched),
          create(:open_library_fetch_task, status: :verified)
        ]
      end
      let!(:author_search_tasks) do
        [
          create(:open_library_author_search_task, status: :requested),
          create(:open_library_author_search_task, status: :fetched),
          create(:open_library_author_search_task, status: :verified)
        ]
      end
      let!(:author_fetch_tasks) do
        author = create(:author)
        identity = create(:external_identity, owner: author, external_id: 'OL1394865A')
        [
          create(:open_library_author_fetch_task, target: identity, status: :requested),
          create(:open_library_author_fetch_task,
                 target: create(:external_identity, owner: create(:author), external_id: 'OL2A'),
                 status: :fetched),
          create(:open_library_author_fetch_task,
                 target: create(:external_identity, owner: create(:author), external_id: 'OL3A'),
                 status: :verified)
        ]
      end

      it 'contains fetched tasks waiting for review' do
        send_request
        expect(assigns(:book_searches)).to eq([book_search_tasks[1]])
        expect(assigns(:book_fetches)).to eq([book_fetch_tasks[1]])
        expect(assigns(:author_searches)).to eq([author_search_tasks[1]])
        expect(assigns(:author_fetches)).to eq([author_fetch_tasks[1]])
      end

      it 'renders column headers and sample link text' do
        send_request
        expect(response.body).to include('Open Library updates for review')
        expect(response.body).to include('Book searches')
        expect(response.body).to include('Book fetches')
        expect(response.body).to include('Author searches')
        expect(response.body).to include('Author fetches')

        book = book_search_tasks[1].book
        expect(response.body).to include("#{book.title} (#{book.year_published}) by #{book.author_names_label}")
        expect(response.body).to include(author_search_tasks[1].author.fullname)
        expect(response.body).to include(author_fetch_tasks[1].author.fullname)
      end
    end
  end
end
