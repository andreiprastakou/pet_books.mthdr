require 'rails_helper'

RSpec.describe Admin::Books::CollectionBatchController do
  let(:author) { create(:author, fullname: 'Title Author') }
  let(:collection) do
    create(:book, title: 'Collected Stories', literary_form: 'collection', year_published: 1984, authors: [author])
  end
  let(:included_work) { create(:book, title: 'Included Work', authors: [author], literary_form: 'novel') }

  describe 'GET /admin/books/:book_id/collection_batch/edit' do
    let(:send_request) { get edit_admin_book_collection_batch_path(collection), headers: authorization_header }

    before do
      create(:external_link, owner: collection, url: 'https://example.com/collection')
      create(:book_collection, collection: collection, book: included_work)
      create(:book, title: 'Unrelated Work', authors: [author])
    end

    it 'renders the collection batch edit page' do
      send_request

      expect(response).to be_successful
      expect(response).to render_template 'admin/books/collection_batch/edit'
      expect(response.body).to include('Collection Batch Edit')
      expect(response.body).to include('title="Skip"')

      references = response.body[/Parental references.*?Books to update:/m]
      expect(references).to include('https://example.com/collection')
      expect(references).not_to include('Collected Stories')
      expect(references).not_to include('Included Work')

      expect(response.body).to include('Included Work')
      expect(response.body).not_to include('Unrelated Work')
    end

    it 'prefills new rows with the collection authors' do
      send_request

      template = response.body[%r{<template[^>]*bookTemplate[\s\S]*?</template>}]
      expect(template).to include(author.id.to_s)
      expect(template).to include(%(data-autocomplete-author-ids-value="[#{author.id}]"))
      expect(template).to include('Title Author')
      expect(template).to include('value="short"')
      expect(template).to include(admin_api_books_search_path(format: :json))
      expect(template).to include('books-batch-form#onExistingBookSelected')
      expect(response.body).to match(
        /name="batch\[ENTRY_INDEX\]\[year_published\]" id="batch_ENTRY_INDEX_year_published"(?! value=)/
      )
      expect(response.body).not_to include('ensure_author_id')
    end

    it 'does not prefill new rows when the collection has more than two authors' do
      authors = create_list(:author, 3)
      anthology = create(:book, title: 'Anthology', literary_form: 'collection', authors: authors)

      get edit_admin_book_collection_batch_path(anthology), headers: authorization_header

      template = response.body[%r{<template[^>]*bookTemplate[\s\S]*?</template>}]
      expect(template).to include('data-values="[]"')
      expect(template).to include(%(data-autocomplete-author-ids-value="#{authors.map(&:id).to_json}"))
      authors.each { |item| expect(template).not_to include(item.fullname) }
    end

    it 'does not render for a book that is not a collection' do
      get edit_admin_book_collection_batch_path(included_work), headers: authorization_header

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT /admin/books/:book_id/collection_batch' do
    let(:send_request) do
      put admin_book_collection_batch_path(collection), params: params, headers: authorization_header
    end

    before { create(:book_collection, collection: collection, book: included_work) }

    context 'when adding a new work' do
      let(:params) do
        {
          batch: {
            0 => {
              id: included_work.id,
              title: included_work.title,
              year_published: included_work.year_published,
              author_ids: [author.id]
            },
            1 => {
              title: 'New Included Work',
              literary_form: 'novel',
              year_published: 2024,
              author_ids: [author.id]
            }
          }
        }
      end

      it 'includes the new book in the collection' do
        expect { send_request }.to change(Joins::BookCollection, :count).by(1)

        new_work = Admin::Book.find_by!(title: 'New Included Work')
        expect(collection.reload.collected_works).to contain_exactly(included_work, new_work)
        expect(response).to redirect_to admin_book_path(collection)
      end
    end

    context 'when adding an existing work that is not in the collection' do
      let(:existing_work) { create(:book, title: 'Fetched Work', authors: [author], literary_form: 'novel') }
      let(:params) do
        {
          batch: {
            0 => {
              id: included_work.id,
              title: included_work.title,
              year_published: included_work.year_published,
              author_ids: [author.id]
            },
            1 => {
              id: existing_work.id,
              title: existing_work.title,
              year_published: existing_work.year_published,
              author_ids: [author.id]
            }
          }
        }
      end

      it 'includes the existing book in the collection' do
        expect { send_request }.to change(Joins::BookCollection, :count).by(1)

        expect(collection.reload.collected_works).to contain_exactly(included_work, existing_work)
        expect(response).to redirect_to admin_book_path(collection)
      end
    end

    context 'when updating an included work' do
      let(:params) do
        {
          batch: {
            0 => {
              id: included_work.id,
              title: 'Renamed Work',
              year_published: included_work.year_published,
              author_ids: [author.id]
            }
          }
        }
      end

      it 'updates the work without adding another collection link' do
        expect { send_request }.not_to change(Joins::BookCollection, :count)
        expect(included_work.reload.title).to eq 'Renamed Work'
        expect(response).to redirect_to admin_book_path(collection)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          batch: {
            0 => {
              title: '',
              year_published: 2024,
              author_ids: [author.id]
            }
          }
        }
      end

      it 'renders the form again without creating a work' do
        expect { send_request }.not_to change(Book, :count)
        expect(response).to render_template 'admin/books/collection_batch/edit'
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:error]).to include("Title can't be blank")
      end
    end
  end
end
