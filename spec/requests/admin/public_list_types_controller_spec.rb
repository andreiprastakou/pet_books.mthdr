require 'rails_helper'

RSpec.describe Admin::PublicListTypesController do
  let(:valid_attributes) do
    {
      name: 'Best Sellers'
    }
  end

  let(:invalid_attributes) do
    {
      name: ''
    }
  end

  let(:public_list_type) { create(:public_list_type) }

  describe 'GET /admin/public_list_types' do
    let(:send_request) { get admin_public_list_types_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_list_types/index'
    end
  end

  describe 'GET /admin/public_list_types/:id' do
    let(:send_request) { get admin_public_list_type_path(public_list_type), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_list_types/show'
    end
  end

  describe 'GET /admin/public_list_types/new' do
    let(:send_request) { get new_admin_public_list_type_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_list_types/new'
    end
  end

  describe 'GET /admin/public_list_types/:id/edit' do
    let(:send_request) { get edit_admin_public_list_type_path(public_list_type), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/public_list_types/edit'
    end
  end

  describe 'POST /admin/public_list_types' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_public_list_types_path, params: { public_list_type: valid_attributes }, headers: authorization_header
      end

      it 'creates a new PublicListType' do
        expect do
          send_request
        end.to change(PublicListType, :count).by(1)
      end

      it 'redirects to the created public list type' do
        send_request
        expect(response).to redirect_to(admin_public_list_type_path(PublicListType.last))
        expect(flash[:notice]).to eq('Public list type was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_public_list_types_path(format: :html),
             params: { public_list_type: invalid_attributes },
             headers: authorization_header
      end

      it 'does not create a new PublicListType' do
        expect do
          send_request
        end.not_to change(PublicListType, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/public_list_types/new'
      end
    end
  end

  describe 'PATCH /admin/public_list_types/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Top Rated'
        }
      end
      let(:send_request) do
        patch admin_public_list_type_path(public_list_type), params: { public_list_type: new_attributes },
                                                             headers: authorization_header
      end

      it 'updates the requested public list type' do
        send_request
        public_list_type.reload
        expect(public_list_type.name).to eq('Top Rated')
      end

      it 'redirects to the public list type' do
        send_request
        expect(response).to redirect_to(admin_public_list_type_path(public_list_type))
        expect(flash[:notice]).to eq('Public list type was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_public_list_type_path(public_list_type),
              params: { public_list_type: invalid_attributes },
              headers: authorization_header
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/public_list_types/edit'
      end
    end
  end

  describe 'DELETE /admin/public_list_types/:id' do
    let(:send_request) { delete admin_public_list_type_path(public_list_type), headers: authorization_header }

    it 'destroys the requested public list type' do
      public_list_type
      expect do
        send_request
      end.to change(PublicListType, :count).by(-1)
    end

    it 'redirects to the public list types list' do
      send_request
      expect(response).to redirect_to(admin_public_list_types_path)
      expect(flash[:notice]).to eq('Public list type was successfully destroyed.')
    end
  end
end
