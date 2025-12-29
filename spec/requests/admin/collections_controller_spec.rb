require 'rails_helper'

RSpec.describe Admin::CollectionsController do
  let(:valid_attributes) do
    {
      name: 'Fantasy Collection',
      year_published: 2020
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      year_published: 1.1
    }
  end

  let(:collection) { create(:collection) }

  describe 'GET /admin/collections' do
    let(:send_request) { get admin_collections_path, headers: authorization_header }

    before do
      create_list(:collection, 3)
    end

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/collections/index'
    end

    context 'with sorting' do
      it 'sorts by id descending by default' do
        send_request
        expect(response).to be_successful
        # The default sort is id desc, so the last created collection should appear first
        expect(assigns(:collections).first.id).to eq(Collection.last.id)
      end

      it 'sorts by name ascending' do
        get admin_collections_path, params: { sort_by: 'name', sort_order: 'asc' }, headers: authorization_header
        expect(response).to be_successful
        names = assigns(:collections).map(&:name)
        expect(names).to eq(names.sort)
      end

      it 'sorts by created_at ascending' do
        get admin_collections_path, params: { sort_by: 'created_at', sort_order: 'asc' }, headers: authorization_header
        expect(response).to be_successful
        created_ats = assigns(:collections).map(&:created_at)
        expect(created_ats).to eq(created_ats.sort)
      end
    end
  end

  describe 'GET /admin/collections/:id' do
    let(:send_request) { get admin_collection_path(collection), headers: authorization_header }

    context 'without books' do
      it 'renders a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template 'admin/collections/show'
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
        collection.books += books
      end

      it 'renders a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template 'admin/collections/show'
      end

      it 'displays books sorted by year_published descending by default' do
        send_request
        expect(response).to be_successful
        years = assigns(:books).map(&:year_published)
        expect(years).to eq([2021, 2020, 2019])
      end

      it 'sorts books by title ascending' do
        get admin_collection_path(collection), params: { sort_by: 'title', sort_order: 'asc' },
                                               headers: authorization_header
        expect(response).to be_successful
        titles = assigns(:books).map(&:title)
        expect(titles).to eq(['Book 1', 'Book 2', 'Book 3'])
      end

      it 'sorts books by year_published ascending' do
        get admin_collection_path(collection), params: { sort_by: 'year_published', sort_order: 'asc' },
                                               headers: authorization_header
        expect(response).to be_successful
        years = assigns(:books).map(&:year_published)
        expect(years).to eq([2019, 2020, 2021])
      end
    end
  end

  describe 'GET /admin/collections/new' do
    let(:send_request) { get new_admin_collection_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/collections/new'
    end
  end

  describe 'GET /admin/collections/:id/edit' do
    let(:send_request) { get edit_admin_collection_path(collection), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/collections/edit'
    end
  end

  describe 'POST /admin/collections' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_collections_path, params: { collection: valid_attributes }, headers: authorization_header
      end

      it 'creates a new Collection' do
        expect do
          send_request
        end.to change(Collection, :count).by(1)
      end

      it 'redirects to the created collection' do
        send_request
        expect(response).to redirect_to(admin_collection_path(Collection.last))
        expect(flash[:notice]).to eq('Collection was successfully created.')
      end

      it 'sets the correct attributes' do
        send_request
        collection = Collection.last
        expect(collection.name).to eq('Fantasy Collection')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_collections_path(format: :html), params: { collection: invalid_attributes },
                                                    headers: authorization_header
      end

      it 'does not create a new Collection' do
        expect do
          send_request
        end.not_to change(Collection, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/collections/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/collections/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Updated Collection Name'
        }
      end
      let(:send_request) do
        patch admin_collection_path(collection), params: { collection: new_attributes }, headers: authorization_header
      end

      it 'updates the requested collection' do
        send_request
        collection.reload
        expect(collection.name).to eq('Updated Collection Name')
      end

      it 'redirects to the collection' do
        send_request
        expect(response).to redirect_to(admin_collection_path(collection))
        expect(flash[:notice]).to eq('Collection was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_collection_path(collection), params: { collection: invalid_attributes },
                                                 headers: authorization_header
      end

      it 'does not update the collection' do
        original_name = collection.name
        send_request
        collection.reload
        expect(collection.name).to eq(original_name)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/collections/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/collections/:id' do
    let(:send_request) { delete admin_collection_path(collection), headers: authorization_header }

    it 'destroys the requested collection' do
      collection
      expect do
        send_request
      end.to change(Collection, :count).by(-1)
    end

    it 'redirects to the collections list' do
      send_request
      expect(response).to redirect_to(admin_collections_path)
      expect(response).to have_http_status(:see_other)
      expect(flash[:notice]).to eq('Collection was successfully destroyed.')
    end

    context 'with associated books' do
      let(:book) { create(:book) }

      before do
        collection.books << book
      end

      it 'deletes the collection but not the books' do
        send_request
        expect(response).to redirect_to(admin_collections_path)
        expect(flash[:notice]).to eq('Collection was successfully destroyed.')
        expect(Collection.count).to eq(0)
        expect(Book.count).to eq(1)
      end
    end
  end
end
