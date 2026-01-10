require 'rails_helper'

RSpec.describe FrontendApi::CoverDesignsController, type: :request do
  describe 'GET #index' do
    subject(:send_request) { get '/api/cover_designs.json', headers: authorization_header }

    let(:cover_designs) { create_list(:cover_design, 3) }

    before { cover_designs }

    it 'returns a successful response' do
      send_request
      expect(response).to be_successful
      expect(json_response).to eq(
        cover_designs.map do |cover_design|
          {
            id: cover_design.id,
            name: cover_design.name,
            title_color: cover_design.title_color, title_font: cover_design.title_font,
            author_name_color: cover_design.author_name_color, author_name_font: cover_design.author_name_font,
            cover_image: cover_design.cover_image
          }
        end
      )
    end
  end
end
