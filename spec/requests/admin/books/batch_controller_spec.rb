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
          }
        }
      }
    end
    let(:book_a) { build_stubbed(:book, author: author, title: 'TITLE_A') }
    let(:author) { create(:author) }
    let(:updater) { instance_double(Forms::Admin::BooksBatchUpdater) }

    before do
      allow(Forms::Admin::BooksBatchUpdater).to receive(:new).and_return(updater)
      allow(updater).to receive(:update).and_return(true)
      allow(updater).to receive(:books).and_return([book_a])
    end

    it 'updates and redirects to the author page' do
      send_request
      expect(updater).to have_received(:update)
      expect(response).to redirect_to admin_author_path(book_a.author)
    end

    context 'with invalid params' do
      before do
        allow(updater).to receive(:update).and_return(false)
        book_a.errors.add(:title, 'SOME_ERROR')
      end

      it 'renders the form again without updating books' do
        send_request
        expect(response).to render_template 'admin/books/batch/edit'
        expect(flash[:error]).to eq 'Failed to apply updates: Title SOME_ERROR.'
      end
    end
  end
end
