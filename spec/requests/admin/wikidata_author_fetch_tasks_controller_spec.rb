require 'rails_helper'

RSpec.describe Admin::WikidataAuthorFetchTasksController do
  let(:author) { create(:author, fullname: 'J. R. R. Tolkien', birth_year: nil, death_year: nil) }
  let!(:external_identity) do
    create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
  end
  let(:fetched_data) do
    {
      'labels' => { 'en' => 'J. R. R. Tolkien' },
      'statements' => {
        'P569' => [
          {
            'rank' => 'normal',
            'value' => {
              'type' => 'value',
              'content' => { 'time' => '+1892-01-03T00:00:00Z', 'precision' => 11 }
            }
          }
        ],
        'P570' => [
          {
            'rank' => 'normal',
            'value' => {
              'type' => 'value',
              'content' => { 'time' => '+1973-09-02T00:00:00Z', 'precision' => 11 }
            }
          }
        ],
        'P648' => [
          { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'OL26320A' } }
        ],
        'P2963' => [
          { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => '2740668' } }
        ]
      },
      'sitelinks' => {
        'enwiki' => {
          'title' => 'J. R. R. Tolkien',
          'url' => 'https://en.wikipedia.org/wiki/J._R._R._Tolkien'
        },
        'enwikiquote' => {
          'title' => 'J. R. R. Tolkien',
          'url' => 'https://en.wikiquote.org/wiki/J._R._R._Tolkien'
        }
      }
    }
  end
  let!(:task) do
    create(
      :wikidata_author_fetch_task,
      target: external_identity,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  describe 'GET /admin/wikidata_author_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_wikidata_author_fetch_task_path(task), headers: authorization_header }

    it 'renders the apply form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:author)).to eq(author)
      expect(response.body).to include('Wikidata fetch results')
      expect(response.body).to include('Born in')
      expect(response.body).to include('Died in')
      expect(response.body).to include('1892')
      expect(response.body).to include('1973')
      expect(response.body).to include('open_library')
      expect(response.body).to include('OL26320A')
      expect(response.body).to include('goodreads')
      expect(response.body).to include('2740668')
      expect(response.body).to include('en.wikipedia.org')
      expect(response.body).to include('b-external-link-icon')
      expect(response.body).to include('en.wikiquote.org')
      expect(assigns(:birth_year)).to eq(1892)
      expect(assigns(:death_year)).to eq(1973)
      expect(assigns(:wikipedia_sitelinks).size).to eq(1)
      expect(assigns(:other_sitelinks)).to eq(
        [
          {
            'external_resource' => 'en.wikiquote.org',
            'url' => 'https://en.wikiquote.org/wiki/J._R._R._Tolkien'
          }
        ]
      )
    end

    context 'when the selected wikipedia url already exists on the author' do
      before do
        create(
          :external_link,
          owner: author,
          external_resource: 'wikipedia',
          url: 'https://en.wikipedia.org/wiki/J._R._R._Tolkien'
        )
      end

      it 'disables the wikipedia add button' do
        send_request
        expect(response.body).to include('disabled')
      end
    end
  end

  describe 'POST /admin/wikidata_author_fetch_tasks/:id/apply_birth_year' do
    let(:send_request) do
      post apply_birth_year_admin_wikidata_author_fetch_task_path(task),
           params: { year: 1892 },
           headers: authorization_header
    end

    it 'updates the birth year and reloads the apply form' do
      send_request
      expect(author.reload.birth_year).to eq(1892)
      expect(response).to redirect_to(edit_admin_wikidata_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('Birth year updated.')
    end
  end

  describe 'POST /admin/wikidata_author_fetch_tasks/:id/apply_death_year' do
    let(:send_request) do
      post apply_death_year_admin_wikidata_author_fetch_task_path(task),
           params: { year: 1973 },
           headers: authorization_header
    end

    it 'updates the death year and reloads the apply form' do
      send_request
      expect(author.reload.death_year).to eq(1973)
      expect(response).to redirect_to(edit_admin_wikidata_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('Death year updated.')
    end
  end

  describe 'POST /admin/wikidata_author_fetch_tasks/:id/add_identity' do
    let(:send_request) do
      post add_identity_admin_wikidata_author_fetch_task_path(task),
           params: { external_resource: 'open_library', external_id: 'OL26320A' },
           headers: authorization_header
    end

    it 'creates an identity and reloads the apply form' do
      expect { send_request }.to change(author.external_identities, :count).by(1)
      expect(response).to redirect_to(edit_admin_wikidata_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('External identity added.')
    end
  end

  describe 'POST /admin/wikidata_author_fetch_tasks/:id/add_wikipedia_link' do
    let(:send_request) do
      post add_wikipedia_link_admin_wikidata_author_fetch_task_path(task),
           params: { url: 'https://en.wikipedia.org/wiki/J._R._R._Tolkien' },
           headers: authorization_header
    end

    it 'creates a wikipedia link and reloads the apply form' do
      expect { send_request }.to change(author.external_links, :count).by(1)
      link = author.external_links.find_by!(url: 'https://en.wikipedia.org/wiki/J._R._R._Tolkien')
      expect(link.external_resource).to eq('wikipedia')
      expect(response).to redirect_to(edit_admin_wikidata_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('Wikipedia link added.')
    end
  end

  describe 'POST /admin/wikidata_author_fetch_tasks/:id/add_link' do
    let(:send_request) do
      post add_link_admin_wikidata_author_fetch_task_path(task),
           params: {
             url: 'https://en.wikiquote.org/wiki/J._R._R._Tolkien',
             external_resource: 'en.wikiquote.org'
           },
           headers: authorization_header
    end

    it 'creates an external link and reloads the apply form' do
      expect { send_request }.to change(author.external_links, :count).by(1)
      expect(response).to redirect_to(edit_admin_wikidata_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('External link added.')
    end
  end
end
