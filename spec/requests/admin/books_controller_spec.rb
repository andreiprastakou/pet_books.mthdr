require 'rails_helper'

RSpec.describe Admin::BooksController do
  let(:author) { create(:author) }
  let(:valid_attributes) do
    {
      title: 'Test Book',
      author_ids: [author.id],
      year_published: 2023
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      author_ids: [author.id],
      year_published: 2023
    }
  end

  let(:book) { create(:book, authors: [author]) }

  describe 'GET /admin/books' do
    let(:send_request) { get admin_books_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/index'
    end
  end

  describe 'GET /admin/books/:id' do
    let(:send_request) { get admin_book_path(book), headers: authorization_header }

    before { create(:cover_design, name: 'default') }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/show'
    end

    it 'renders external identities with fetch links' do
      identity = create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL99W')
      send_request
      expect(response.body).to include('External identities:')
      expect(response.body).to include('Open Library:')
      expect(response.body).to include('OL99W')
      expect(response.body).to include('https://openlibrary.org/works/OL99W')
      expect(response.body).to include(admin_book_external_identity_open_library_fetches_path(book, identity))
      expect(response.body).to include(admin_book_wikidata_searches_path(book))
      expect(response.body).to include(admin_book_library_thing_searches_path(book))
    end

    it 'renders a fetch data link for Wikidata identities' do
      identity = create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q74287')
      send_request
      expect(response.body).to include('Wikidata:')
      expect(response.body).to include('Q74287')
      expect(response.body).to include('https://www.wikidata.org/wiki/Q74287')
      expect(response.body).to include(admin_book_external_identity_wikidata_fetches_path(book, identity))
      expect(response.body).to include(admin_book_open_library_searches_path(book))
      expect(response.body).not_to include(admin_book_wikidata_searches_path(book))
      expect(response.body).to include(admin_book_library_thing_searches_path(book))
    end

    it 'renders search links when Open Library, Wikidata, and LibraryThing identities are missing' do
      send_request
      expect(response.body).to include(admin_book_open_library_searches_path(book))
      expect(response.body).to include(admin_book_wikidata_searches_path(book))
      expect(response.body).to include(admin_book_library_thing_searches_path(book))
      expect(response.body).to include('>search</a>')
    end

    it 'does not list collected works when the book is not a collection' do
      send_request
      expect(response.body).not_to include('>FORM</a>')
    end

    context 'when the book is a collection' do
      let(:older_work) { create(:book, title: 'Older Work', year_published: 1990, authors: [author]) }
      let(:newer_work) { create(:book, title: 'Newer Work', year_published: 2001, authors: [author]) }
      let(:book) do
        create(:book, literary_form: 'collection', authors: [author]).tap do |collection|
          create(:book_collection, collection: collection, book: older_work)
          create(:book_collection, collection: collection, book: newer_work)
        end
      end

      it 'lists collected works newest first' do
        send_request
        expect(response.body).to include('>FORM</a>')
        expect(response.body).to include('Older Work')
        expect(response.body).to include('Newer Work')
        expect(response.body.index('Newer Work')).to be < response.body.index('Older Work')
        expect(response.body).to include(admin_book_path(newer_work))
      end
    end

    it 'hides the LibraryThing search link when a LibraryThing identity exists' do
      create(:external_identity, owner: book, external_resource: :librarything, external_id: '33363109')
      send_request
      expect(response.body).to include('Librarything:')
      expect(response.body).to include('33363109')
      expect(response.body).to include('https://www.librarything.com/work/33363109')
      expect(response.body).not_to include(admin_book_library_thing_searches_path(book))
    end
  end

  describe 'GET /admin/books/new' do
    let(:send_request) { get new_admin_book_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/new'
    end
  end

  describe 'GET /admin/books/:id/edit' do
    let(:send_request) { get edit_admin_book_path(book), headers: authorization_header }

    it 'renders a successful response with external identities section' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/edit'
      expect(response.body).to include('External Identities')
      expect(response.body).to include('add identity')
    end

    it 'renders literary form as a single-select dropdown of predefined forms' do
      send_request
      expect(response.body).to include('name="book[literary_form]"')
      expect(response.body).to include('<option value=""')
      LiteraryForm::DEFAULTS.each do |form|
        expect(response.body).to include(%(<option value="#{form}">#{form.humanize}</option>))
      end
      expect(response.body).not_to include('will be replaced!')
    end

    it 'warns when the saved literary form is not a predefined option' do
      book.update!(literary_form: 'audio_drama')
      send_request
      expect(response.body).to include("Current value 'audio_drama' will be replaced!")
      expect(response.body).not_to include('<option value="audio_drama"')
    end

    it 'hides collected works when the book has none and is not a collection' do
      send_request
      expect(response.body).to match(/data-book-form-target="collectedWorksSection"\s+hidden/)
    end

    context 'when the book has collected works' do
      let(:work) { create(:book, title: 'Inner Work', literary_form: 'novel', authors: [author]) }
      let(:book) do
        create(:book, literary_form: 'collection', authors: [author]).tap do |collection|
          create(:book_collection, collection: collection, book: work)
        end
      end

      it 'lists the works and shows the add input' do
        send_request
        expect(response.body).to include('Collected works')
        expect(response.body).to include('Inner Work')
        expect(response.body).to include(%(data-autocomplete-author-ids-value="#{book.author_ids.to_json}"))
        input = response.body[/class="col-md-6 b-collected-works-input"[^>]*/]
        expect(input).to be_present
        expect(input).not_to include('hidden')
      end

      context 'when the saved form is not collection' do
        before { book.update!(literary_form: 'novel') }

        it 'lists the works and hides the add input' do
          send_request
          expect(response.body).to include('Inner Work')
          expect(response.body).not_to match(/data-book-form-target="collectedWorksSection"\s+hidden/)
          input = response.body[/class="col-md-6 b-collected-works-input"[^>]*/]
          expect(input).to include('hidden')
        end
      end
    end
  end

  describe 'POST /admin/books' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_books_path, params: { book: valid_attributes }, headers: authorization_header
      end

      it 'creates a new Book' do
        expect do
          send_request
        end.to change(Book, :count).by(1)
      end

      it 'redirects to the created book' do
        send_request
        expect(response).to redirect_to(admin_book_path(Book.last))
        expect(flash[:notice]).to eq('Book was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_books_path(format: :html), params: { book: invalid_attributes }, headers: authorization_header
      end

      it 'does not create a new Book' do
        expect do
          send_request
        end.not_to change(Book, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/books/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/books/:id' do
    let(:new_attributes) do
      {
        title: 'Updated Book Title'
      }
    end
    let(:send_request) do
      patch admin_book_path(book), params: { book: new_attributes }, headers: authorization_header
    end

    it 'updates the requested book' do
      send_request
      book.reload
      expect(book.title).to eq('Updated Book Title')
    end

    it 'creates external identities from nested attributes' do
      patch admin_book_path(book),
            params: {
              book: {
                title: book.title,
                external_identities_attributes: {
                  '0' => { external_resource: 'goodreads', external_id: '99999' }
                }
              }
            },
            headers: authorization_header

      expect(book.external_identities.reload.find_by(external_resource: :goodreads).external_id).to eq('99999')
    end

    it 'redirects to the book' do
      send_request
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('Book was successfully updated.')
    end

    it 'replaces collected works' do
      collection = create(:book, literary_form: 'collection', authors: [author])
      kept = create(:book, literary_form: 'novel', title: 'Kept Work')
      removed = create(:book, literary_form: 'novel', title: 'Removed Work')
      added = create(:book, literary_form: 'novel', title: 'Added Work')
      create(:book_collection, collection: collection, book: kept)
      create(:book_collection, collection: collection, book: removed)

      patch admin_book_path(collection),
            params: { book: { collected_work_ids: [kept.id.to_s, added.id.to_s, ''] } },
            headers: authorization_header

      expect(collection.reload.collected_works).to contain_exactly(kept, added)
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_book_path(book), params: { book: invalid_attributes }, headers: authorization_header
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/books/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/books/:id' do
    let(:send_request) { delete admin_book_path(book), headers: authorization_header }

    it 'destroys the requested book' do
      book
      expect do
        send_request
      end.to change(Book, :count).by(-1)
    end

    it 'redirects to the books list' do
      send_request
      expect(response).to redirect_to(admin_books_path)
      expect(flash[:notice]).to eq('Book was successfully destroyed.')
    end
  end
end
