require 'rails_helper'

RSpec.describe Admin::Books::BatchController do
  describe 'PUT /admin/books/batch' do
    let(:send_request) { put admin_books_batch_path, params: params, headers: authorization_header }
    let(:params) do
      {
        batch: {
          0 => {
            id: book_a.id,
            title: 'TITLE_A_UPDATED'
          },
          1 => {
            title: 'TITLE_B',
            original_title: 'ORIGINAL_TITLE_B',
            literary_form: 'novel',
            year_published: '2025',
            author_id: author.id,
            goodreads_url: 'GOODREADS_URL_B',
            wiki_url: 'WIKI_URL_B'
          }
        }
      }
    end
    let(:book_a) { create(:book, author: author, title: 'TITLE_A') }
    let(:author) { create(:author) }

    it 'updates books with IDs' do
      send_request
      expect(book_a.reload.title).to eq 'TITLE_A_UPDATED'
    end

    it 'creates books with no IDs' do
      book_a
      expect { send_request }.to change(Book, :count).by(1)
      book_b = Book.last
      aggregate_failures do
        expect(book_b.title).to eq 'TITLE_B'
        expect(book_b.original_title).to eq 'ORIGINAL_TITLE_B'
        expect(book_b.literary_form).to eq 'novel'
        expect(book_b.year_published).to eq 2025
        expect(book_b.author_id).to eq author.id
        expect(book_b.goodreads_url).to eq 'GOODREADS_URL_B'
        expect(book_b.wiki_url).to eq 'WIKI_URL_B'
      end
    end

    it 'renders a successful response' do
      send_request
      expect(response).to redirect_to admin_author_path(book_a.author)
    end

    context 'with invalid params' do
      before do
        params[:batch][2] = params[:batch][1].dup
        params[:batch][1][:title] = ''
      end

      it 'renders the form again without updating books' do
        book_a
        expect { send_request }.not_to change(Book, :count)
        expect(book_a.reload.title).to eq 'TITLE_A'
        expect(assigns(:books)).to contain_exactly(book_a, kind_of(Book), kind_of(Book))
        expect(assigns(:books)[1].errors).to be_present
      end

      it 'renders the books batch edit page' do
        send_request
        expect(response).to render_template 'admin/books/batch/edit'
        expect(flash[:error]).to eq 'Failed to apply updates: Title can\'t be blank.'
      end
    end
  end
end
