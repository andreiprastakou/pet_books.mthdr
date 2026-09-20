require 'rails_helper'

RSpec.describe Admin::Feed::AiWorksWidgetController do
  describe 'GET /admin/feed/ai_works_widget' do
    let(:send_request) { get admin_feed_ai_works_widget_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/ai_works_widget/show'
    end

    describe 'rendered data' do
      let(:books) { create_list(:book, 3, literary_form: 'novel') }
      let(:summaries) do
        [
          create(:book_summary_task, target: books[0], status: :requested),
          create(:book_summary_task, target: books[1], status: :fetched),
          create(:book_summary_task, target: books[2], status: :verified)
        ]
      end
      let(:synced_authors) { create_list(:author, 3, synced_at: Time.current) }
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
        summaries
        fetched_lists
        parsed_lists
      end

      it 'contains AI works waiting for review' do
        send_request
        expect(assigns(:summaries_to_verify)).to contain_exactly(summaries[1])
        expect(assigns(:summaries_to_verify_count)).to eq(1)
        expect(assigns(:fetched_lists_to_verify)).to contain_exactly(fetched_lists[1])
        expect(assigns(:fetched_lists_to_verify_count)).to eq(1)
        expect(assigns(:parsed_lists_to_verify)).to contain_exactly(parsed_lists[1])
        expect(assigns(:parsed_lists_to_verify_count)).to eq(1)
      end

      it 'renders column headers with totals and filter links' do
        send_request
        expect(response.body).to include('AI works')
        expect(response.body).not_to include('Books for data filling')
        expect(response.body).to include('Book data generated')
        expect(response.body).to include('Author works fetches')
        expect(response.body).to include('Author works parses')
        expect(response.body).to include('1 total')

        expect(response.body).to include(
          ERB::Util.html_escape(
            admin_data_fetch_tasks_path(type: Admin::Tasks::AiBookFetch.name, status: :fetched, commit: 'Filter')
          )
        )
        expect(response.body).to include(
          ERB::Util.html_escape(
            admin_data_fetch_tasks_path(type: Admin::Tasks::AiAuthorWorksFetch.name, status: :fetched, commit: 'Filter')
          )
        )
        expect(response.body).to include(
          ERB::Util.html_escape(
            admin_data_fetch_tasks_path(type: Admin::Tasks::AiAuthorWorksParse.name, status: :fetched, commit: 'Filter')
          )
        )

        book = books[1]
        expect(response.body).to include("#{book.title} (#{book.year_published}) by #{book.author_names_label}")
        expect(response.body).to include(synced_authors[1].fullname)
      end
    end
  end
end
