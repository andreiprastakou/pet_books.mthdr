require 'rails_helper'

RSpec.describe Admin::PublicListsController do
  let(:public_list_type) { create(:public_list_type) }
  let(:valid_attributes) do
    {
      public_list_type_id: public_list_type.id,
      year: 2023
    }
  end

  let(:invalid_attributes) do
    {
      public_list_type_id: public_list_type.id,
      year: -1
    }
  end

  let(:public_list) { create(:public_list, public_list_type: public_list_type) }

  describe 'GET /admin/public_list_type/:public_list_type_id/public_lists/:id' do
    let(:send_request) do
      get admin_public_list_type_public_list_path(public_list_type, public_list),
          params: params, headers: authorization_header
    end
    let(:params) { {} }

    context 'without books' do
      it 'renders a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template 'admin/public_lists/show'
      end
    end

    context 'with books' do
      let(:books) do
        [
          create(:book, title: 'Book 1', year_published: 2020),
          create(:book, title: 'Book 2', year_published: 2021),
          create(:book, title: 'Book 3', year_published: 2019)
        ]
      end

      before do
        public_list.book_public_lists.build(book: books[0], role: "winner_c")
        public_list.book_public_lists.build(book: books[1], role: "winner_b")
        public_list.book_public_lists.build(book: books[2], role: "winner_a")
        public_list.save!
      end

      it 'renders a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template 'admin/public_lists/show'
      end

      it 'displays books sorted by roles descending by default' do
        send_request
        expect(response).to be_successful
        roles = assigns(:book_public_lists).map(&:role)
        expect(roles).to eq(['winner_c', 'winner_b', 'winner_a'])
      end

      context 'with sorting' do
        let(:params) { { sort_by: 'title', sort_order: 'asc' } }

        it 'allows to sort books by title ascending' do
          send_request
          expect(response).to be_successful
          titles = assigns(:book_public_lists).map { |book_public_list| book_public_list.book.title }
          expect(titles).to eq(['Book 1', 'Book 2', 'Book 3'])
        end
      end

      context 'with sorting' do
        let(:params) { { sort_by: 'year_published', sort_order: 'asc' } }

        it 'allows to sort books by year_published ascending' do
          send_request
          expect(response).to be_successful
          years = assigns(:book_public_lists).map { |book_public_list| book_public_list.book.year_published }
          expect(years).to eq([2019, 2020, 2021])
        end
      end
    end
  end

  describe 'GET /admin/public_list_type/:public_list_type_id/public_lists/new' do
    let(:send_request) do
      get new_admin_public_list_type_public_list_path(public_list_type), headers: authorization_header
    end

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_lists/new'
    end
  end

  describe 'GET /admin/public_list_type/:public_list_type_id/public_lists/:id/edit' do
    let(:send_request) do
      get edit_admin_public_list_type_public_list_path(public_list_type, public_list), headers: authorization_header
    end

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_lists/edit'
    end
  end

  describe 'POST /admin/public_list_type/:public_list_type_id/public_lists' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_public_list_type_public_lists_path(public_list_type), params: { public_list: valid_attributes },
          headers: authorization_header
      end

      it 'creates a new PublicList' do
        expect do
          send_request
        end.to change(PublicList, :count).by(1)
      end

      it 'redirects to the created public list' do
        send_request
        expect(response).to redirect_to(admin_public_list_type_public_list_path(public_list_type, PublicList.last))
        expect(flash[:notice]).to eq('Public list was successfully created.')
      end

      it 'sets the correct attributes' do
        send_request
        list = PublicList.last
        expect(list.public_list_type_id).to eq(public_list_type.id)
        expect(list.year).to eq(2023)
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_public_list_type_public_lists_path(public_list_type), params: { public_list: invalid_attributes },
                                                     headers: authorization_header
      end

      it 'does not create a new PublicList' do
        expect do
          send_request
        end.not_to change(PublicList, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/public_lists/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/public_list_type/:public_list_type_id/public_lists/:id' do
    let(:send_request) do
      patch admin_public_list_type_public_list_path(public_list_type, public_list),
            params: params,
            headers: authorization_header
    end
    let(:params) { { public_list: new_attributes } }

    context 'with valid parameters' do
      let(:new_attributes) do
        {
          year: 2024
        }
      end

      it 'updates the requested public list' do
        send_request
        public_list.reload
        expect(public_list.year).to eq(2024)
      end

      it 'redirects to the public list' do
        send_request
        expect(response).to redirect_to(admin_public_list_type_public_list_path(public_list_type, public_list))
        expect(flash[:notice]).to eq('Public list was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:params) { { public_list: invalid_attributes } }

      it 'does not update the public list' do
        original_year = public_list.year
        send_request
        public_list.reload
        expect(public_list.year).to eq(original_year)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/public_lists/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/public_lists/:id' do
    let(:send_request) do
      delete admin_public_list_type_public_list_path(public_list_type, public_list), headers: authorization_header
    end

    it 'destroys the requested public list' do
      public_list
      expect do
        send_request
      end.to change(PublicList, :count).by(-1)
    end

    it 'redirects to the public lists list' do
      send_request
      expect(response).to redirect_to(admin_public_list_type_path(public_list_type))
      expect(flash[:notice]).to eq('Public list was successfully destroyed.')
    end

    context 'with associated books' do
      let(:book) { create(:book) }

      before do
        public_list.books << book
      end

      it 'deletes the public list but not the books' do
        send_request
        expect(PublicList.count).to eq(0)
        expect(Book.count).to eq(1)
      end
    end
  end
end
