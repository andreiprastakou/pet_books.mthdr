require 'rails_helper'

RSpec.describe Admin::FeedController do
  describe 'GET /admin/feed' do
    let(:send_request) { get admin_root_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/feed/show'
    end
  end
end
