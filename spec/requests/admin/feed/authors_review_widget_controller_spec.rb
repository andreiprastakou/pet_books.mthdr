require 'rails_helper'

RSpec.describe Admin::Feed::AuthorsReviewWidgetController do
  describe 'GET /admin/feed/authors_review_widget' do
    let(:send_request) { get admin_feed_authors_review_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/authors_review_widget/show'
    end

    describe 'rendered data' do
      let(:authors_to_sync) { create_list(:author, 3) }
      let(:synced_authors) { create_list(:author, 3, synced_at: Time.current) }
      let(:authors) { authors_to_sync + synced_authors }
      let(:fetched_lists) do
        [
          create(:author_books_list_task, target: synced_authors[0], status: :requested),
          create(:author_books_list_task, target: synced_authors[1], status: :fetched),
          create(:author_books_list_task, target: synced_authors[2], status: :verified)
        ]
      end
      let(:parsed_lists) do
        [
          create(:author_books_list_parsing_task, target: synced_authors[0], status: :requested),
          create(:author_books_list_parsing_task, target: synced_authors[1], status: :fetched),
          create(:author_books_list_parsing_task, target: synced_authors[2], status: :verified)
        ]
      end

      before do
        authors
        fetched_lists
        parsed_lists
      end

      it 'contains authors to sync and lists to verify' do
        send_request
        expect(assigns(:authors_to_sync)).to match_array(authors_to_sync)
        expect(assigns(:fetched_lists_to_verify)).to contain_exactly(fetched_lists[1])
        expect(assigns(:parsed_lists_to_verify)).to contain_exactly(parsed_lists[1])
      end
    end
  end
end
