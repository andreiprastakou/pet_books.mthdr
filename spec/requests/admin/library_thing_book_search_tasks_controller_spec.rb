require 'rails_helper'

RSpec.describe Admin::LibraryThingBookSearchTasksController do
  let(:book) { create(:book, title: 'Some Book') }
  let(:fetched_data) do
    JSON.parse(
      Rails.root.join(
        'engines/admin/spec/fixtures/library_thing/book_search_by_title.json'
      ).read
    )
  end
  let(:task) do
    create(
      :library_thing_search_task,
      target: book,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  describe 'GET /admin/library_thing_book_search_tasks/:id/edit' do
    let(:send_request) { get edit_admin_library_thing_book_search_task_path(task), headers: authorization_header }

    it 'renders usable values with an add-to-book form' do
      send_request
      expect(response).to be_successful
      expect(response.body).to include('LibraryThing search results')
      expect(response.body).to include('https://www.librarything.com/work/31661953')
      expect(response.body).to include('librarything')
      expect(response.body).to include('add to the book')
      expect(response.body).not_to include('disabled')
    end

    context 'when the book already has that LibraryThing link' do
      before do
        create(
          :external_link,
          owner: book,
          external_resource: ExternalResources::LIBRARYTHING,
          url: 'https://www.librarything.com/work/31661953'
        )
      end

      it 'disables the add button' do
        send_request
        expect(response).to be_successful
        expect(response.body).to include('disabled')
      end
    end
  end

  describe 'POST /admin/library_thing_book_search_tasks/:id/add_work_link' do
    let(:send_request) do
      post add_work_link_admin_library_thing_book_search_task_path(task),
           params: { url: 'https://www.librarything.com/work/31661953' },
           headers: authorization_header
    end

    it 'creates an external link and reloads the apply form' do
      expect { send_request }.to change(book.external_links, :count).by(1)
      expect(task.reload.status).to eq('fetched')
      expect(response).to redirect_to(edit_admin_library_thing_book_search_task_path(task))
      expect(flash[:notice]).to eq('LibraryThing link added.')
    end

    context 'when url is invalid' do
      let(:send_request) do
        post add_work_link_admin_library_thing_book_search_task_path(task),
             params: { url: 'not-a-librarything-url' },
             headers: authorization_header
      end

      it 're-renders the apply form with an error' do
        expect { send_request }.not_to change(book.external_links, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:edit)
        expect(flash[:error]).to eq('Invalid LibraryThing work url')
      end
    end
  end
end
