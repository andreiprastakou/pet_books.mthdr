require 'rails_helper'

RSpec.describe Admin::SeriesController do
  let(:valid_attributes) do
    {
      name: 'Fantasy Series'
    }
  end

  let(:invalid_attributes) do
    {
      name: ''
    }
  end

  let(:series) { create(:series) }

  describe 'GET /admin/series' do
    let(:send_request) { get admin_series_index_path, headers: authorization_header }

    before do
      create_list(:series, 3)
    end

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/series/index'
    end

    context 'with sorting' do
      it 'sorts by id descending by default' do
        send_request
        expect(response).to be_successful
        # The default sort is id desc, so the last created series should appear first
        expect(assigns(:series).first.id).to eq(Series.last.id)
      end

      it 'sorts by name ascending' do
        get admin_series_index_path, params: { sort_by: 'name', sort_order: 'asc' }, headers: authorization_header
        expect(response).to be_successful
        names = assigns(:series).map(&:name)
        expect(names).to eq(names.sort)
      end

      it 'sorts by created_at ascending' do
        get admin_series_index_path, params: { sort_by: 'created_at', sort_order: 'asc' }, headers: authorization_header
        expect(response).to be_successful
        created_ats = assigns(:series).map(&:created_at)
        expect(created_ats).to eq(created_ats.sort)
      end
    end
  end

  describe 'GET /admin/series/:id' do
    let(:send_request) { get admin_series_path(series), headers: authorization_header }

    context 'without books' do
      it 'renders a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template 'admin/series/show'
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
        series.books += books
      end

      it 'renders a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template 'admin/series/show'
      end

      it 'displays books sorted by year_published descending by default' do
        send_request
        expect(response).to be_successful
        years = assigns(:books).map(&:year_published)
        expect(years).to eq([2021, 2020, 2019])
      end

      it 'sorts books by title ascending' do
        get admin_series_path(series), params: { sort_by: 'title', sort_order: 'asc' }, headers: authorization_header
        expect(response).to be_successful
        titles = assigns(:books).map(&:title)
        expect(titles).to eq(['Book 1', 'Book 2', 'Book 3'])
      end

      it 'sorts books by year_published ascending' do
        get admin_series_path(series), params: { sort_by: 'year_published', sort_order: 'asc' },
                                       headers: authorization_header
        expect(response).to be_successful
        years = assigns(:books).map(&:year_published)
        expect(years).to eq([2019, 2020, 2021])
      end
    end
  end

  describe 'GET /admin/series/new' do
    let(:send_request) { get new_admin_series_path, headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/series/new'
    end
  end

  describe 'GET /admin/series/:id/edit' do
    let(:send_request) { get edit_admin_series_path(series), headers: authorization_header }

    it 'renders a successful response' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/series/edit'
    end
  end

  describe 'POST /admin/series' do
    context 'with valid parameters' do
      let(:send_request) do
        post admin_series_index_path, params: { series: valid_attributes }, headers: authorization_header
      end

      it 'creates a new Series' do
        expect do
          send_request
        end.to change(Series, :count).by(1)
      end

      it 'redirects to the created series' do
        send_request
        expect(response).to redirect_to(admin_series_path(Series.last))
        expect(flash[:notice]).to eq('Series was successfully created.')
      end

      it 'sets the correct attributes' do
        send_request
        series = Series.last
        expect(series.name).to eq('Fantasy Series')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        post admin_series_index_path(format: :html), params: { series: invalid_attributes },
                                                     headers: authorization_header
      end

      it 'does not create a new Series' do
        expect do
          send_request
        end.not_to change(Series, :count)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/series/new'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /admin/series/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Updated Series Name'
        }
      end
      let(:send_request) do
        patch admin_series_path(series), params: { series: new_attributes }, headers: authorization_header
      end

      it 'updates the requested series' do
        send_request
        series.reload
        expect(series.name).to eq('Updated Series Name')
      end

      it 'redirects to the series' do
        send_request
        expect(response).to redirect_to(admin_series_path(series))
        expect(flash[:notice]).to eq('Series was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:send_request) do
        patch admin_series_path(series), params: { series: invalid_attributes }, headers: authorization_header
      end

      it 'does not update the series' do
        original_name = series.name
        send_request
        series.reload
        expect(series.name).to eq(original_name)
      end

      it 'renders the form again' do
        send_request
        expect(response).to render_template 'admin/series/edit'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/series/:id' do
    let(:send_request) { delete admin_series_path(series), headers: authorization_header }

    it 'destroys the requested series' do
      series
      expect do
        send_request
      end.to change(Series, :count).by(-1)
    end

    it 'redirects to the series list' do
      send_request
      expect(response).to redirect_to(admin_series_index_path)
      expect(response).to have_http_status(:see_other)
      expect(flash[:notice]).to eq('Series was successfully destroyed.')
    end
  end
end
