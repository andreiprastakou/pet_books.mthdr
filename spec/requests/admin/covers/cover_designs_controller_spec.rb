require 'rails_helper'

RSpec.describe Admin::Covers::CoverDesignsController do
  describe 'GET /admin/covers/cover_designs' do
    let(:send_request) { get admin_covers_cover_designs_path, headers: authorization_header }
    let(:cover_designs) { create_list(:cover_design, 3) }

    before { cover_designs }

    it 'renders designs' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/covers/cover_designs/index'
      expect(assigns(:designs)).to match_array(cover_designs)
    end
  end

  describe 'GET /admin/covers/cover_designs/new' do
    let(:send_request) { get new_admin_covers_cover_design_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/covers/cover_designs/new'
      expect(assigns(:design)).to be_a_new(CoverDesign)
    end
  end

  describe 'POST /admin/covers/cover_designs' do
    let(:send_request) { post admin_covers_cover_designs_path, params: params, headers: authorization_header }
    let(:params) do
      {
        cover_design: {
          name: 'test_cover_design_name',
          title_font: 'font_a',
          title_color: 'color_a',
          author_name_font: 'font_a',
          author_name_color: 'color_a',
          cover_image: 'Test Cover Image'
        }
      }
    end

    it 'creates a new cover design' do
      expect { send_request }.to change(CoverDesign, :count).by(1)
      cover_design = CoverDesign.last
      aggregate_failures do
        expect(cover_design.name).to eq('test_cover_design_name')
        expect(cover_design.title_font).to eq('font_a')
        expect(cover_design.title_color).to eq('color_a')
        expect(cover_design.author_name_font).to eq('font_a')
        expect(cover_design.author_name_color).to eq('color_a')
        expect(cover_design.cover_image).to eq('Test Cover Image')
      end
    end

    it 'redirects to the cover design index' do
      send_request
      expect(response).to redirect_to(admin_covers_cover_designs_path)
      expect(flash[:notice]).to eq('Cover design was successfully created.')
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          cover_design: { name: '' }
        }
      end

      it 'renders the form again' do
        expect { send_request }.not_to change(CoverDesign, :count)
        expect(response).to render_template 'admin/covers/cover_designs/new'
        expect(assigns(:design).errors).to be_present
      end
    end
  end

  describe 'GET /admin/covers/cover_designs/:id/edit' do
    let(:send_request) { get edit_admin_covers_cover_design_path(cover_design), headers: authorization_header }
    let(:cover_design) { create(:cover_design) }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/covers/cover_designs/edit'
      expect(assigns(:design)).to eq(cover_design)
    end
  end

  describe 'PUT /admin/covers/cover_designs/:id' do
    let(:send_request) do
      put admin_covers_cover_design_path(cover_design), params: params, headers: authorization_header
    end
    let(:params) do
      {
        cover_design: {
          name: 'test_cover_design_name_updated',
          title_font: 'font_a_updated'
        }
      }
    end
    let(:cover_design) { create(:cover_design, name: 'test_cover_design_name', title_font: 'font_a') }

    it 'updates the cover design' do
      send_request
      expect(response).to redirect_to(admin_covers_cover_designs_path)
      expect(flash[:notice]).to eq('Cover design was successfully updated.')
      cover_design.reload
      aggregate_failures do
        expect(cover_design.name).to eq('test_cover_design_name_updated')
        expect(cover_design.title_font).to eq('font_a_updated')
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          cover_design: { name: '' }
        }
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/covers/cover_designs/edit'
        expect(assigns(:design).errors).to be_present
      end
    end
  end

  describe 'DELETE /admin/covers/cover_designs/:id' do
    let(:send_request) { delete admin_covers_cover_design_path(cover_design), headers: authorization_header }
    let(:cover_design) { create(:cover_design) }

    before { cover_design }

    it 'destroys the cover design' do
      expect { send_request }.to change(CoverDesign, :count).by(-1)
      expect(response).to redirect_to(admin_covers_cover_designs_path)
      expect(flash[:notice]).to eq('Cover design was successfully destroyed.')
    end

    context 'when a genre still uses the design' do
      before { create(:genre, cover_design: cover_design) }

      it 'keeps the design and explains why' do
        expect { send_request }.not_to change(CoverDesign, :count)
        expect(response).to redirect_to(edit_admin_covers_cover_design_path(cover_design))
        expect(flash[:alert]).to eq('Cannot delete this record because other records still depend on it.')
      end
    end
  end
end
