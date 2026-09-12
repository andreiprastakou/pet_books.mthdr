require 'rails_helper'

RSpec.describe Admin::Feed::OpenLibraryBookFetchesWidgetController do
  describe 'GET /admin/feed/open_library_book_fetches_widget' do
    let(:send_request) { get admin_feed_open_library_book_fetches_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/open_library_book_fetches_widget/show'
    end

    describe 'rendered data' do
      let!(:tasks) do
        [
          create(:open_library_fetch_task, status: :requested),
          create(:open_library_fetch_task, status: :fetched),
          create(:open_library_fetch_task, status: :verified)
        ]
      end

      it 'contains fetched tasks waiting for review' do
        send_request
        expect(assigns(:tasks)).to eq([tasks[1]])
        expect(assigns(:tasks_count)).to eq(1)
      end
    end
  end
end
