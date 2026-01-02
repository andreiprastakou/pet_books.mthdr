require 'rails_helper'

RSpec.describe Admin::TagsController do
  let(:valid_attributes) do
    {
      name: 'Mystery',
      category: 'genre'
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      category: 'genre'
    }
  end

  let(:tag) { create(:tag, category: 'genre') }

  describe 'GET /admin/tags' do
    let(:send_request) { get admin_tags_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/tags/index'
    end
  end

  describe 'GET /admin/tags/:id' do
    let(:send_request) { get admin_tag_path(tag), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/tags/show'
    end
  end

  describe 'GET /admin/tags/new' do
    let(:send_request) { get new_admin_tag_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/tags/new'
    end
  end

  describe 'GET /admin/tags/:id/edit' do
    let(:send_request) { get edit_admin_tag_path(tag), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/tags/edit'
    end
  end

  describe 'POST /admin/tags' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_tags_path, params: { tag: valid_attributes }, headers: authorization_header
      end

      it 'creates a new Tag' do
        expect do
          send_request
        end.to change(Tag, :count).by(1)
      end

      it 'redirects to the created tag' do
        send_request
        expect(response).to redirect_to(admin_tag_path(Tag.last))
        expect(flash[:notice]).to eq('Tag was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_tags_path(format: :html), params: { tag: invalid_attributes }, headers: authorization_header
      end

      it 'does not create a new Tag' do
        expect do
          send_request
        end.not_to change(Tag, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/tags/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/tags/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Thriller',
          category: 'genre'
        }
      end
      let(:send_request) do
        patch admin_tag_path(tag), params: { tag: new_attributes }, headers: authorization_header
      end

      it 'updates the requested tag' do
        send_request
        tag.reload
        expect(tag.name).to eq('thriller')
        expect(tag.category).to eq('genre')
      end

      it 'redirects to the tag' do
        send_request
        expect(response).to redirect_to(admin_tag_path(tag))
        expect(flash[:notice]).to eq('Tag was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_tag_path(tag), params: { tag: invalid_attributes }, headers: authorization_header
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/tags/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/tags/:id' do
    let(:send_request) { delete admin_tag_path(tag), headers: authorization_header }

    it 'destroys the requested tag' do
      tag
      expect do
        send_request
      end.to change(Tag, :count).by(-1)
    end

    it 'redirects to the tags list' do
      send_request
      expect(response).to redirect_to(admin_tags_path)
      expect(flash[:notice]).to eq('Tag was successfully destroyed.')
    end
  end
end
