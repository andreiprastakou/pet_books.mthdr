require 'rails_helper'

RSpec.describe Admin::Books::ExternalIdentitiesController do
  let(:book) { create(:book) }
  let(:external_identity) do
    create(:external_identity, owner: book, external_resource: :open_library, external_id: 'OL1W')
  end

  let(:valid_attributes) do
    {
      external_resource: 'wikidata',
      external_id: 'Q123'
    }
  end

  let(:invalid_attributes) do
    {
      external_resource: 'open_library',
      external_id: external_identity.external_id
    }
  end

  describe 'GET /admin/books/:book_id/external_identities/:id' do
    let(:send_request) do
      get admin_book_external_identity_path(book, external_identity), headers: authorization_header
    end

    it 'renders a successful response with identity details' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/external_identities/show'
      expect(response.body).to include('Open Library')
      expect(response.body).to include('OL1W')
    end
  end

  describe 'GET /admin/books/:book_id/external_identities/new' do
    let(:send_request) { get new_admin_book_external_identity_path(book), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/external_identities/new'
    end
  end

  describe 'GET /admin/books/:book_id/external_identities/:id/edit' do
    let(:send_request) do
      get edit_admin_book_external_identity_path(book, external_identity), headers: authorization_header
    end

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/books/external_identities/edit'
    end
  end

  describe 'POST /admin/books/:book_id/external_identities' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_book_external_identities_path(book),
             params: { external_identity: valid_attributes },
             headers: authorization_header
      end

      it 'creates a new ExternalIdentity for the book' do
        expect { send_request }.to change(book.external_identities, :count).by(1)
        identity = book.external_identities.order(:id).last
        expect(identity.external_resource).to eq('wikidata')
        expect(identity.external_id).to eq('Q123')
      end

      it 'redirects to the created external identity' do
        send_request
        identity = ExternalIdentity.order(:id).last
        expect(response).to redirect_to(admin_book_external_identity_path(book, identity))
        expect(flash[:notice]).to eq('External identity was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_book_external_identities_path(book),
             params: { external_identity: invalid_attributes },
             headers: authorization_header
      end

      before { external_identity }

      it 'does not create a new ExternalIdentity' do
        expect { send_request }.not_to change(ExternalIdentity, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/books/external_identities/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/books/:book_id/external_identities/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          external_resource: 'goodreads',
          external_id: 'gr-99'
        }
      end
      let(:send_request) do
        patch admin_book_external_identity_path(book, external_identity),
              params: { external_identity: new_attributes },
              headers: authorization_header
      end

      it 'updates the requested external identity' do
        send_request
        external_identity.reload
        expect(external_identity.external_resource).to eq('goodreads')
        expect(external_identity.external_id).to eq('gr-99')
      end

      it 'redirects to the external identity' do
        send_request
        expect(response).to redirect_to(admin_book_external_identity_path(book, external_identity))
        expect(flash[:notice]).to eq('External identity was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let!(:other_identity) do
        create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q999')
      end
      let(:send_request) do
        patch admin_book_external_identity_path(book, external_identity),
              params: {
                external_identity: {
                  external_resource: 'wikidata',
                  external_id: other_identity.external_id
                }
              },
              headers: authorization_header
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/books/external_identities/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/books/:book_id/external_identities/:id' do
    let(:send_request) do
      delete admin_book_external_identity_path(book, external_identity), headers: authorization_header
    end

    it 'destroys the requested external identity' do
      external_identity
      expect { send_request }.to change(ExternalIdentity, :count).by(-1)
    end

    it 'redirects to the book' do
      send_request
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq('External identity was successfully destroyed.')
    end
  end
end
