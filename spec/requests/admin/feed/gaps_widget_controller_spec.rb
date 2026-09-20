require 'rails_helper'

RSpec.describe Admin::Feed::GapsWidgetController do
  describe 'GET /admin/feed/gaps_widget' do
    let(:send_request) { get admin_feed_gaps_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/gaps_widget/show'
    end

    describe 'rendered data' do
      let(:books) do
        create_list(:book, 6, literary_form: 'novel') +
          create_list(:book, 3, data_filled: true, literary_form: 'novel')
      end
      let(:authors_to_sync) { create_list(:author, 3) }
      let(:synced_authors) { create_list(:author, 3, synced_at: Time.current) }

      before do
        books.each { |book| book.authors.find_each { |author| author.update!(synced_at: Time.current) } }
        authors_to_sync
        synced_authors
        create(:book_summary_task, target: books[3], status: :requested)
        create(:book_summary_task, target: books[4], status: :fetched)
        create(:book_summary_task, target: books[5], status: :verified)
      end

      it 'contains books and authors with gaps' do
        send_request
        expect(assigns(:books)).to match_array(books[0..2])
        expect(assigns(:books_count)).to eq(3)
        expect(assigns(:authors)).to match_array(authors_to_sync)
        expect(assigns(:authors_count)).to eq(3)
      end

      it 'renders column headers and book/author links' do
        send_request
        expect(response.body).to include('Gaps')
        expect(response.body).to include('Books (3 total)')
        expect(response.body).to include('Authors (3 total)')

        book = books[0]
        expect(response.body).to include("#{book.title} (#{book.year_published}) by #{book.author_names_label}")
        expect(response.body).to include(admin_book_path(book))
        expect(response.body).to include(authors_to_sync.first.fullname)
        expect(response.body).to include(admin_author_path(authors_to_sync.first))
      end
    end
  end
end
