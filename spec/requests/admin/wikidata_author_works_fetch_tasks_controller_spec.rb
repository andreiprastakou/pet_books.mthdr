# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WikidataAuthorWorksFetchTasksController do
  let(:author) { create(:author) }
  let!(:existing_book) { create(:book, authors: [author], title: 'Old Title', year_published: 1950) }
  let(:fetched_data) do
    [
      {
        'work' => 'Q100',
        'work_label' => 'New Title',
        'publication_date' => '1955-01-01T00:00:00Z',
        'type_label' => 'novel'
      },
      {
        'work' => 'Q200',
        'work_label' => 'Brand New Work',
        'publication_date' => '1960-01-01T00:00:00Z',
        'type_label' => 'novella'
      }
    ]
  end
  let!(:task) do
    create(
      :wikidata_author_works_fetch_task,
      target: author,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  before do
    create(:external_identity, owner: existing_book, external_resource: :wikidata, external_id: 'Q100')
  end

  describe 'GET /admin/wikidata_author_works_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_wikidata_author_works_fetch_task_path(task), headers: authorization_header }

    it 'renders combined author books and wikidata works' do
      send_request
      expect(response).to be_successful
      expect(response.body).to include('Wikidata author works')
      expect(response.body).to include('New Title')
      expect(response.body).to include('Brand New Work')
      expect(response.body).to include('novel')
      expect(response.body).to include('Q100')
      expect(response.body).to include('Q200')
      expect(response.body).to include(admin_book_path(existing_book))
      expect(response.body).to include('update')
      expect(response.body).to include('add')
      expect(response.body).to include('b-reversible-input-container')
      expect(response.body).to match(/b-reversible-input-container[^"]*\bnew\b/)
      expect(response.body).to include('form="wikidata_author_work_row_')
      expect(response.body).to include('name="book_id"')
      expect(response.body).to include("#{existing_book.id}: Old Title (1950)")
    end
  end

  describe 'POST /admin/wikidata_author_works_fetch_tasks/:id/apply_work' do
    context 'when updating an existing matched book' do
      let(:send_request) do
        post apply_work_admin_wikidata_author_works_fetch_task_path(task),
             params: {
               book_id: existing_book.id,
               title: 'New Title',
               year: '1955',
               entity_id: 'Q100'
             },
             headers: authorization_header
      end

      it 'updates the book and redirects' do
        send_request
        expect(response).to redirect_to(edit_admin_wikidata_author_works_fetch_task_path(task))
        expect(existing_book.reload.title).to eq('New Title')
        expect(existing_book.year_published).to eq(1955)
      end
    end

    context 'when adding a new work' do
      let(:send_request) do
        post apply_work_admin_wikidata_author_works_fetch_task_path(task),
             params: {
               title: 'Brand New Work',
               year: '1960',
               entity_id: 'Q200'
             },
             headers: authorization_header
      end

      it 'creates a book with the author and wikidata identity' do
        expect { send_request }.to change(Book, :count).by(1)
        book = Admin::Book.order(:id).last
        expect(book.title).to eq('Brand New Work')
        expect(book.year_published).to eq(1960)
        expect(book.authors).to contain_exactly(author)
        expect(book.external_identities.wikidata.find_by!(external_id: 'Q200')).to be_present
        expect(response).to redirect_to(edit_admin_wikidata_author_works_fetch_task_path(task))
      end
    end

    context 'when linking an unmatched work to an existing book via book_id' do
      let!(:other_book) { create(:book, authors: [author], title: 'Other Book', year_published: 1965) }
      let(:send_request) do
        post apply_work_admin_wikidata_author_works_fetch_task_path(task),
             params: {
               book_id: other_book.id,
               title: 'Brand New Work',
               year: '1960',
               entity_id: 'Q200'
             },
             headers: authorization_header
      end

      it 'updates the selected book and adds the wikidata identity' do
        expect { send_request }.not_to change(Book, :count)
        expect(other_book.reload.title).to eq('Brand New Work')
        expect(other_book.year_published).to eq(1960)
        expect(other_book.external_identities.wikidata.find_by!(external_id: 'Q200')).to be_present
        expect(response).to redirect_to(edit_admin_wikidata_author_works_fetch_task_path(task))
      end
    end
  end
end
