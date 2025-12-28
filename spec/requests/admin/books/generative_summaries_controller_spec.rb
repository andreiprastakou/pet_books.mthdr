require 'rails_helper'

RSpec.describe Admin::Books::GenerativeSummariesController do
  describe 'POST /admin/books/:book_id/generative_summaries' do
    let(:send_request) { post admin_book_generative_summaries_path(book), headers: authorization_header }
    let(:book) { create(:book) }
    let(:task) { build_stubbed(:book_summary_task, target: book) }

    before do
      allow(Admin::BookSummaryTask).to receive(:setup).with(kind_of(Admin::BookForm)).and_return(task)
      allow(task).to receive(:perform)
    end

    it 'creates a task and redirects to the book page' do
      expect { send_request }.to have_enqueued_job(Admin::DataFetchJob).with(task.id)
      expect(response).to redirect_to(admin_book_path(book))
    end
  end

  describe 'GET /admin/books/:book_id/generative_summaries/:id/edit' do
    let(:send_request) { get edit_admin_book_generative_summary_path(book, task), headers: authorization_header }
    let(:book) { create(:book) }
    let(:task) { create(:book_summary_task, target: book, fetched_data: summaries, status: :fetched) }
    let(:summaries) do
      [
        { 'summary' => 'SUMMARY_A', 'themes' => 'theme_a', 'genre' => 'genre_a', 'src' => 'src_a' },
        { 'summary' => 'SUMMARY_B', 'themes' => 'theme_b', 'genre' => 'genre_b', 'src' => 'src_b' }
      ]
    end

    it 'renders the template' do
      send_request
      expect(response).to render_template('admin/books/generative_summaries/edit')
      aggregate_failures do
        expect(assigns(:book)).to be_a(Admin::BookForm)
        expect(assigns(:summaries)).to eq(task.fetched_data.map(&:symbolize_keys))
        expect(assigns(:all_themes)).to match_array(%w[theme_a theme_b])
      end
    end
  end

  describe 'POST /admin/books/:book_id/generative_summaries/:id/apply' do
    let(:send_request) do
      post apply_admin_book_generative_summary_path(book, task), params: params, headers: authorization_header
    end
    let(:book) { create(:book) }
    let(:task) { create(:book_summary_task, target: book, status: :fetched, fetched_data: []) }
    let(:params) do
      {
        book: {
          title: 'UPDATED_TITLE',
          original_title: 'UPDATED_ORIGINAL_TITLE',
          year_published: '2026',
          author_ids: book.author_ids,
          summary: 'UPDATED_SUMMARY',
          summary_src: 'UPDATED_SUMMARY_SRC',
          literary_form: 'UPDATED_LITERARY_FORM',
          data_filled: true,
          tag_names: %w[tag_a tag_b],
          genre_names: %w[genre_a genre_b]
        },
        summary_verified: true
      }
    end

    it 'updates the book' do
      send_request
      book.reload
      aggregate_failures do
        expect(book.title).to eq('UPDATED_TITLE')
        expect(book.original_title).to eq('UPDATED_ORIGINAL_TITLE')
        expect(book.year_published).to eq(2026)
        expect(book.summary).to eq('UPDATED_SUMMARY')
        expect(book.summary_src).to eq('UPDATED_SUMMARY_SRC')
        expect(book.literary_form).to eq('UPDATED_LITERARY_FORM')
        expect(book.genres.map(&:genre_name)).to eq(%w[genre_a genre_b])
        expect(book.tags.map(&:name)).to eq(%w[tag_a tag_b])
        expect(book.data_filled).to be true
      end
    end

    it 'marks the task as verified' do
      send_request
      expect(task.reload).to be_verified
    end

    it 'redirects to the book page' do
      send_request
      expect(response).to redirect_to(admin_book_path(book))
    end

    context 'with invalid parameters' do
      before { params[:book][:title] = '' }

      it 'renders the form again and keeps the task not verified' do
        send_request
        expect(response).to render_template('admin/books/generative_summaries/edit')
        expect(task.reload).not_to be_verified
      end
    end
  end
end
