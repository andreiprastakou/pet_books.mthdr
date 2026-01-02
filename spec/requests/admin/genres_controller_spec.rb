require 'rails_helper'

RSpec.describe Admin::GenresController do
  let(:valid_attributes) do
    {
      name: 'Science Fiction'
    }
  end

  let(:invalid_attributes) do
    {
      name: ''
    }
  end

  let(:genre) { create(:genre) }

  describe 'GET /admin/genres' do
    let(:send_request) { get admin_genres_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/genres/index'
    end
  end

  describe 'GET /admin/genres/:id' do
    let(:send_request) { get admin_genre_path(genre), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/genres/show'
    end
  end

  describe 'GET /admin/genres/new' do
    let(:send_request) { get new_admin_genre_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/genres/new'
    end
  end

  describe 'GET /admin/genres/:id/edit' do
    let(:send_request) { get edit_admin_genre_path(genre), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/genres/edit'
    end
  end

  describe 'POST /admin/genres' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_genres_path, params: { genre: valid_attributes }, headers: authorization_header
      end

      it 'creates a new Genre' do
        expect do
          send_request
        end.to change(Genre, :count).by(1)
      end

      it 'redirects to the created genre' do
        send_request
        expect(response).to redirect_to(admin_genre_path(Genre.last))
        expect(flash[:notice]).to eq('Genre was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_genres_path(format: :html), params: { genre: invalid_attributes }, headers: authorization_header
      end

      it 'does not create a new Genre' do
        expect do
          send_request
        end.not_to change(Genre, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/genres/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/genres/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Fantasy'
        }
      end
      let(:send_request) do
        patch admin_genre_path(genre), params: { genre: new_attributes }, headers: authorization_header
      end

      it 'updates the requested genre' do
        send_request
        genre.reload
        expect(genre.name).to eq('fantasy')
      end

      it 'redirects to the genre' do
        send_request
        expect(response).to redirect_to(admin_genre_path(genre))
        expect(flash[:notice]).to eq('Genre was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_genre_path(genre), params: { genre: invalid_attributes }, headers: authorization_header
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/genres/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/genres/:id' do
    let(:send_request) { delete admin_genre_path(genre), headers: authorization_header }

    it 'destroys the requested genre' do
      genre
      expect do
        send_request
      end.to change(Genre, :count).by(-1)
    end

    it 'redirects to the genres list' do
      send_request
      expect(response).to redirect_to(admin_genres_path)
      expect(flash[:notice]).to eq('Genre was successfully destroyed.')
    end
  end
end
