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

  describe 'GET /admin/public_lists' do
    let(:send_request) { get admin_public_lists_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_lists/index'
    end
  end

  describe 'GET /admin/public_lists/:id' do
    let(:send_request) { get admin_public_list_path(public_list), headers: authorization_header }

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
        public_list.books += books
      end

      it 'renders a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template 'admin/public_lists/show'
      end

      it 'displays books sorted by year_published descending by default' do
        send_request
        expect(response).to be_successful
        years = assigns(:books).map(&:year_published)
        expect(years).to eq([2021, 2020, 2019])
      end

      it 'sorts books by title ascending' do
        get admin_public_list_path(public_list), params: { sort_by: 'title', sort_order: 'asc' },
                                                 headers: authorization_header
        expect(response).to be_successful
        titles = assigns(:books).map(&:title)
        expect(titles).to eq(['Book 1', 'Book 2', 'Book 3'])
      end

      it 'sorts books by year_published ascending' do
        get admin_public_list_path(public_list), params: { sort_by: 'year_published', sort_order: 'asc' },
                                                 headers: authorization_header
        expect(response).to be_successful
        years = assigns(:books).map(&:year_published)
        expect(years).to eq([2019, 2020, 2021])
      end
    end
  end

  describe 'GET /admin/public_lists/new' do
    let(:send_request) { get new_admin_public_list_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_lists/new'
    end
  end

  describe 'GET /admin/public_lists/:id/edit' do
    let(:send_request) { get edit_admin_public_list_path(public_list), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_lists/edit'
    end
  end

  describe 'POST /admin/public_lists' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_public_lists_path, params: { public_list: valid_attributes }, headers: authorization_header
      end

      it 'creates a new PublicList' do
        expect do
          send_request
        end.to change(PublicList, :count).by(1)
      end

      it 'redirects to the created public list' do
        send_request
        expect(response).to redirect_to(admin_public_list_path(PublicList.last))
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
        post admin_public_lists_path(format: :html), params: { public_list: invalid_attributes },
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
      end
    end
  end

  describe 'PATCH /admin/public_lists/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          year: 2024
        }
      end
      let(:send_request) do
        patch admin_public_list_path(public_list),
              params: { public_list: new_attributes },
              headers: authorization_header
      end

      it 'updates the requested public list' do
        send_request
        public_list.reload
        expect(public_list.year).to eq(2024)
      end

      it 'redirects to the public list' do
        send_request
        expect(response).to redirect_to(admin_public_list_path(public_list))
        expect(flash[:notice]).to eq('Public list was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_public_list_path(public_list),
              params: { public_list: invalid_attributes },
              headers: authorization_header
      end

      it 'does not update the public list' do
        original_year = public_list.year
        send_request
        public_list.reload
        expect(public_list.year).to eq(original_year)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/public_lists/edit'
      end
    end
  end

  describe 'DELETE /admin/public_lists/:id' do
    let(:send_request) { delete admin_public_list_path(public_list), headers: authorization_header }

    it 'destroys the requested public list' do
      public_list
      expect do
        send_request
      end.to change(PublicList, :count).by(-1)
    end

    it 'redirects to the public lists list' do
      send_request
      expect(response).to redirect_to(admin_public_lists_path)
      expect(flash[:notice]).to eq('Public list was successfully destroyed.')
    end

    context 'with associated books' do
      let(:book) { create(:book) }

      before do
        public_list.books << book
      end

      it 'deletes the public list but not the books' do
        send_request
        expect(response).to redirect_to(admin_public_lists_path)
        expect(flash[:notice]).to eq('Public list was successfully destroyed.')
        expect(PublicList.count).to eq(0)
        expect(Book.count).to eq(1)
      end
    end
  end
end
