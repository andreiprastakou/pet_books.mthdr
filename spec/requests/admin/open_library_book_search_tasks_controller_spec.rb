require 'rails_helper'

RSpec.describe Admin::OpenLibraryBookSearchTasksController do
  let(:author) { create(:author, fullname: 'Jules Verne') }
  let(:book) { create(:book, title: 'The Sea Serpent', authors: [author]) }
  let(:task) do
    create(
      :open_library_book_search_task,
      target: book,
      status: :fetched,
      fetched_data: [
        {
          'key' => '/works/OL1099866W',
          'title' => 'The sea serpent',
          'author_key' => ['OL113611A'],
          'author_name' => ['Jules Verne'],
          'first_publish_year' => 1967
        }
      ]
    )
  end

  describe 'GET /admin/open_library_book_search_tasks/:id/edit' do
    let(:send_request) { get edit_admin_open_library_book_search_task_path(task), headers: authorization_header }

    it 'renders the selection form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:book)).to eq(book)
      expect(assigns(:search_results).size).to eq(1)
      expect(response.body).to include('add to the book')
      expect(response.body).to include('add to the author')
      expect(response.body).to include('https://openlibrary.org/works/OL1099866W')
      expect(response.body).to include('https://openlibrary.org/authors/OL113611A')
    end

    context 'when results have different publish years' do
      let(:book) { create(:book, title: 'The Sea Serpent', year_published: 1901, authors: [author]) }
      let(:task) do
        create(
          :open_library_book_search_task,
          target: book,
          status: :fetched,
          fetched_data: [
            { 'key' => '/works/OL1W', 'first_publish_year' => 1967 },
            { 'key' => '/works/OL2W', 'first_publish_year' => 1900 },
            { 'key' => '/works/OL3W', 'first_publish_year' => 1850 }
          ]
        )
      end

      it 'sorts results by increasing year difference from the book' do
        send_request
        expect(assigns(:search_results).map { |result| result['external_id'] }).to eq(
          ['/works/OL2W', '/works/OL3W', '/works/OL1W']
        )
      end
    end

    context 'when Open Library identities exist' do
      before do
        create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL1099866W')
        create(:external_identity, owner: author, external_resource: :open_library, external_id: 'OL113611A')
      end

      it 'renders linked identities and disables matching add buttons' do
        send_request
        expect(response.body).to include('Jules Verne')
        expect(response.body).to include('disabled')
      end
    end

    context 'when author identity belongs to an author not on the book' do
      let(:other_author) { create(:author, fullname: 'Other Author') }

      before do
        create(:external_identity, owner: other_author, external_resource: :open_library, external_id: 'OL113611A')
      end

      it 'shows a hint that the author is not linked to the book' do
        send_request
        expect(response.body).to include('Author "Other Author" is not linked to this book.')
      end
    end
  end

  describe 'POST /admin/open_library_book_search_tasks/:id/add_work_identity' do
    let(:send_request) do
      post add_work_identity_admin_open_library_book_search_task_path(task),
           params: { work_key: '/works/OL1099866W' },
           headers: authorization_header
    end

    it 'creates a work identity and reloads the apply form' do
      expect { send_request }.to change(book.external_identities, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_open_library_book_search_task_path(task))
      expect(flash[:notice]).to eq('Open Library work identity added.')
    end
  end

  describe 'POST /admin/open_library_book_search_tasks/:id/add_author_identity' do
    let(:send_request) do
      post add_author_identity_admin_open_library_book_search_task_path(task),
           params: { author_key: 'OL113611A', author_id: author.id },
           headers: authorization_header
    end

    it 'creates an author identity and reloads the apply form' do
      expect { send_request }.to change(author.external_identities, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_open_library_book_search_task_path(task))
      expect(flash[:notice]).to eq('Open Library author identity added.')
    end
  end
end
