require 'rails_helper'

RSpec.describe Admin::Authors::BooksListController do
  let(:author) { create(:author) }

  describe 'POST /admin/authors/:id/books_list' do
    let(:send_request) { post admin_author_books_list_index_path(author), headers: authorization_header }
    let(:task) { build_stubbed(:author_books_list_task, target: author) }

    before do
      allow(Admin::AuthorBooksListTask).to receive(:setup).with(author).and_return(task)
    end

    it 'creates a task and enqueues a job' do
      expect { send_request }.to have_enqueued_job(Admin::DataFetchJob).with(task.id)
    end

    it 'redirects to the author page' do
      send_request
      expect(response).to redirect_to(admin_author_path(author))
    end
  end

  describe 'GET /admin/authors/:id/books_list/:id/edit' do
    let(:send_request) { get edit_admin_author_books_list_path(author, task), headers: authorization_header }
    let(:task) do
      create(:author_books_list_task, target: author, fetched_data: fetched_data, status: :fetched)
    end
    let(:fetched_data) do
      [
        { 'title' => 'BOOK_1', 'original_title' => 'ORIGINAL_1', 'year_published' => 2025,
          'literary_form' => 'type_11', 'wiki_url' => 'https://en.wikipedia.org/wiki/Book_11' },
        { 'title' => 'BOOK_2_DIFFERENT', 'original_title' => 'ORIGINAL_2', 'year_published' => 2025,
          'literary_form' => 'type_22', 'wiki_url' => 'https://en.wikipedia.org/wiki/Book_22' },
        { 'title' => 'BOOK_4', 'original_title' => 'ORIGINAL_4', 'year_published' => 2024,
          'literary_form' => 'type_4', 'wiki_url' => 'https://en.wikipedia.org/wiki/Book_4' }
      ]
    end
    let(:books) do
      [
        create(:book, authors: [author], title: 'BOOK_1', original_title: 'ORIGINAL_1', year_published: 2021,
                      literary_form: 'type_1', wiki_url: 'https://en.wikipedia.org/wiki/Book_1'),
        create(:book, authors: [author], title: 'BOOK_2', original_title: 'ORIGINAL_2', year_published: 2022,
                      literary_form: 'type_2', wiki_url: 'https://en.wikipedia.org/wiki/Book_2'),
        create(:book, authors: [author], title: 'BOOK_3', original_title: 'ORIGINAL_3', year_published: 2023,
                      literary_form: 'type_3', wiki_url: 'https://en.wikipedia.org/wiki/Book_3')
      ]
    end

    before do
      books
    end

    it 'prepares and applies book updates and renders the edit template' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/authors/books_list/edit'
      expect(assigns(:books).map do |b|
        [b.id, b.title, b.original_title, b.year_published, b.literary_form, b.wiki_url]
      end).to eq(
        [
          [books[0].id, 'BOOK_1', 'ORIGINAL_1', 2025, 'type_11', 'https://en.wikipedia.org/wiki/Book_11'],
          [books[1].id, 'BOOK_2_DIFFERENT', 'ORIGINAL_2', 2025, 'type_22', 'https://en.wikipedia.org/wiki/Book_22'],
          [books[2].id, 'BOOK_3', 'ORIGINAL_3', 2023, 'type_3', 'https://en.wikipedia.org/wiki/Book_3'],
          [nil, 'BOOK_4', 'ORIGINAL_4', 2024, 'type_4', 'https://en.wikipedia.org/wiki/Book_4']
        ]
      )
    end
  end

  describe 'POST /admin/authors/:id/books_list/:id/apply' do
    let(:send_request) do
      post apply_admin_author_books_list_path(author, task), params: params, headers: authorization_header
    end
    let(:task) { create(:author_books_list_task, target: author, status: :fetched, fetched_data: []) }
    let(:params) do
      {
        batch: {
          0 => {
            id: book.id,
            title: 'UPDATED_TITLE',
            original_title: 'UPDATED_ORIGINAL_TITLE',
            year_published: '2025',
            author_ids: [author.id],
            literary_form: 'novel',
            wiki_url: 'https://en.wikipedia.org/wiki/Updated_Book'
          }
        }
      }
    end
    let(:book) { create(:book, authors: [author], title: 'ORIGINAL_TITLE') }
    let(:updater) { instance_double(Admin::BooksBatchUpdater) }

    before do
      book
      allow(Admin::BooksBatchUpdater).to receive(:new).and_return(updater)
      allow(updater).to receive_messages(update: true, books: [book])
    end

    it 'updates books via the updater' do
      send_request
      expect(updater).to have_received(:update)
    end

    it 'marks the task as verified' do
      send_request
      expect(task.reload).to be_verified
    end

    it 'redirects to the data fetch task page' do
      send_request
      expect(response).to redirect_to(admin_data_fetch_task_path(task))
    end

    context 'with invalid params' do
      before do
        allow(updater).to receive_messages(update: false, collect_errors: 'Title cannot be blank')
      end

      it 'renders the edit template again' do
        send_request
        expect(response).to render_template 'admin/authors/books_list/edit'
      end

      it 'sets an error flash message' do
        send_request
        expect(flash[:error]).to include('Title cannot be blank')
      end

      it 'does not mark the task as verified' do
        send_request
        expect(task.reload).not_to be_verified
      end
    end
  end
end
