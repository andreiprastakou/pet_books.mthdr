require 'rails_helper'

RSpec.describe Admin::PublicLists::BooksBatchController do
  let(:author) { create(:author, fullname: 'Title Author') }
  let(:public_list_type) { create(:public_list_type, name: 'Hugo Award') }
  let(:public_list) { create(:public_list, public_list_type: public_list_type, year: 1984) }
  let(:included_work) { create(:book, title: 'Included Work', authors: [author], year_published: 1983) }

  describe 'GET /admin/public_list_types/:public_list_type_id/public_lists/:public_list_id/books_batch/edit' do
    let(:send_request) do
      get edit_admin_public_list_type_public_list_books_batch_path(public_list_type, public_list),
          headers: authorization_header
    end

    before do
      create(:external_link, owner: public_list, url: 'https://example.com/list')
      create(:book_public_list, public_list: public_list, book: included_work, role: 'winner_a')
      create(:book, title: 'Unrelated Work', authors: [author])
    end

    it 'renders the public list books batch edit page' do
      send_request

      expect(response).to be_successful
      expect(response).to render_template 'admin/public_lists/books_batch/edit'
      expect(response.body).to include('Books Batch Edit')
      expect(response.body).to include('title="Skip"')

      references = response.body[/Parental references.*?Books to update:/m]
      expect(references).to include('https://example.com/list')
      expect(references).not_to include('Hugo Award')
      expect(references).not_to include('1984')
      expect(references).not_to include('Included Work')

      expect(response.body).to include('Included Work')
      expect(response.body).not_to include('Unrelated Work')
      expect(response.body).to include('b-books-batch-membership')
      expect(response.body).to include('name="batch[0][membership][role]"')
      expect(response.body).to include('value="winner_a"')
      expect(response.body).to include('membership_column=public_list_role')
    end

    it 'prefills new rows with the list year minus one' do
      send_request

      expect(response.body).to include(
        'name="batch[ENTRY_INDEX][literary_form]" id="batch_ENTRY_INDEX_literary_form" ' \
        'class="form-select form-select-sm"'
      )
      expect(response.body).to include('<option value="novel">Novel</option>')
      expect(response.body).not_to include('type="text" name="batch[ENTRY_INDEX][literary_form]"')
      expect(response.body).to include(
        'name="batch[ENTRY_INDEX][year_published]" id="batch_ENTRY_INDEX_year_published" value="1983"'
      )
      expect(response.body).to match(/data-values="\[\]"[\s\S]*?batch\[ENTRY_INDEX\]\[author_ids\]/)
    end
  end

  describe 'PUT /admin/public_list_types/:public_list_type_id/public_lists/:public_list_id/books_batch' do
    let(:send_request) do
      put admin_public_list_type_public_list_books_batch_path(public_list_type, public_list),
          params: params, headers: authorization_header
    end

    before { create(:book_public_list, public_list: public_list, book: included_work, role: 'nominee') }

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
              title: 'New Listed Work',
              literary_form: 'novel',
              year_published: 1983,
              author_ids: [author.id]
            }
          }
        }
      end

      it 'adds the new book to the public list' do
        expect { send_request }.to change(Joins::BookPublicList, :count).by(1)

        new_work = Admin::Book.find_by!(title: 'New Listed Work')
        expect(public_list.reload.books).to contain_exactly(included_work, new_work)
        expect(response).to redirect_to admin_public_list_type_public_list_path(public_list_type, public_list)
      end
    end

    context 'when adding an existing work that is not on the list' do
      let(:existing_work) { create(:book, title: 'Fetched Work', authors: [author], year_published: 1982) }
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

      it 'adds the existing book to the public list' do
        expect { send_request }.to change(Joins::BookPublicList, :count).by(1)

        expect(public_list.reload.books).to contain_exactly(included_work, existing_work)
        expect(response).to redirect_to admin_public_list_type_public_list_path(public_list_type, public_list)
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

      it 'updates the work without adding another list link or clearing its role' do
        expect { send_request }.not_to change(Joins::BookPublicList, :count)
        expect(included_work.reload.title).to eq 'Renamed Work'
        expect(public_list.book_public_lists.find_by!(book: included_work).role).to eq 'nominee'
        expect(response).to redirect_to admin_public_list_type_public_list_path(public_list_type, public_list)
      end
    end

    context 'when assigning roles' do
      let(:params) do
        {
          batch: {
            0 => {
              id: included_work.id,
              title: included_work.title,
              year_published: included_work.year_published,
              author_ids: [author.id],
              membership: { role: 'winner_b' }
            },
            1 => {
              title: 'New Listed Work',
              literary_form: 'novel',
              year_published: 1983,
              author_ids: [author.id],
              membership: { role: '' }
            }
          }
        }
      end

      it 'writes the role on each list membership' do
        send_request

        new_work = Admin::Book.find_by!(title: 'New Listed Work')
        roles = public_list.book_public_lists.order(:book_id).map { |join| [join.book_id, join.role] }
        expect(roles).to contain_exactly([included_work.id, 'winner_b'], [new_work.id, nil])
        expect(response).to redirect_to admin_public_list_type_public_list_path(public_list_type, public_list)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          batch: {
            0 => {
              title: '',
              year_published: 1983,
              author_ids: [author.id],
              membership: { role: 'winner_c' }
            }
          }
        }
      end

      it 'renders the form again without creating a work' do
        expect { send_request }.not_to change(Book, :count)
        expect(response).to render_template 'admin/public_lists/books_batch/edit'
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:error]).to include("Title can't be blank")
        expect(response.body).to include('value="winner_c"')
        expect(Joins::BookPublicList.where(public_list: public_list, role: 'winner_c')).not_to exist
      end
    end
  end
end
