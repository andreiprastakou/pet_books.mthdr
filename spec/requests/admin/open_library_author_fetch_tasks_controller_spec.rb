require 'rails_helper'

RSpec.describe Admin::OpenLibraryAuthorFetchTasksController do
  let(:author) { create(:author, fullname: 'Dean Koontz', birth_year: nil, death_year: nil) }
  let!(:external_identity) do
    create(:external_identity, owner: author, external_resource: :open_library, external_id: 'OL33088A')
  end
  let(:fetched_data) do
    JSON.parse(
      Rails.root.join(
        'engines/admin/spec/fixtures/open_library/author_fetch_dean_koontz.json'
      ).read
    )
  end
  let!(:task) do
    create(
      :open_library_author_fetch_task,
      target: external_identity,
      status: :fetched,
      fetched_data: fetched_data
    )
  end

  describe 'GET /admin/open_library_author_fetch_tasks/:id/edit' do
    let(:send_request) { get edit_admin_open_library_author_fetch_task_path(task), headers: authorization_header }

    it 'renders the apply form' do
      send_request
      expect(response).to be_successful
      expect(assigns(:author)).to eq(author)
      expect(response.body).to include('Open Library author fetch results')
      expect(response.body).to include('Born in')
      expect(response.body).to include('1945')
      expect(response.body).to include('wikidata')
      expect(response.body).to include('https://www.wikidata.org/wiki/Q272076')
      expect(response.body).to include('goodreads')
      expect(response.body).to include('https://www.goodreads.com/author/show/9355')
      expect(response.body).to include('librarything')
      expect(response.body).to include('https://www.librarything.com/author/koontzdean')
      expect(response.body).not_to include('>viaf<')
      expect(response.body).to include('Official Web Site')
      expect(response.body).to include('http://www.deankoontz.com/')
      expect(response.body).to include('Dean Koontz Books in Order')
      expect(response.body).to include('b-external-link-icon')
      expect(response.body).to include('Description')
      expect(response.body).to include('value="add"')
      expect(assigns(:bio)).to include('<sup>1</sup>')
      expect(assigns(:bio)).not_to include('[1][1]')
    end

    context 'when the author already has matching identity and link' do
      before do
        create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q272076')
        create(
          :external_link,
          owner: author,
          external_resource: 'Official Web Site',
          url: 'http://www.deankoontz.com/'
        )
        author.update!(birth_year: 1945)
      end

      it 'disables matching identity add and link update-label buttons' do
        send_request
        expect(response.body).to include('disabled')
        expect(response.body).to include('update label')
        expect(response.body).to include('value="update"')
      end
    end

    context 'when the author has a link with a different label' do
      before do
        create(
          :external_link,
          owner: author,
          external_resource: 'Homepage',
          url: 'http://www.deankoontz.com/'
        )
      end

      it 'shows the old label hint and an enabled update-label button' do
        send_request
        expect(response.body).to include('data-old-value="Homepage"')
        expect(response.body).to include('was &lt;')
        expect(response.body).to include('value="update label"')
        expect(response.body).not_to match(/value="update label"[^>]*disabled/)
      end
    end

    context 'when the author has a different birth year' do
      before { author.update!(birth_year: 1940) }

      it 'shows the original birth year in an input-changes hint' do
        send_request
        expect(response.body).to include('data-old-value="1940"')
        expect(response.body).to include('was &lt;')
        expect(response.body).to include('value="update"')
      end
    end
  end

  describe 'POST /admin/open_library_author_fetch_tasks/:id/apply_birth_year' do
    let(:send_request) do
      post apply_birth_year_admin_open_library_author_fetch_task_path(task),
           params: { year: 1945 },
           headers: authorization_header
    end

    it 'updates birth year and reloads the apply form' do
      expect { send_request }.to change { author.reload.birth_year }.from(nil).to(1945)
      expect(response).to redirect_to(edit_admin_open_library_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('Birth year updated.')
    end
  end

  describe 'POST /admin/open_library_author_fetch_tasks/:id/apply_description' do
    let(:send_request) do
      post apply_description_admin_open_library_author_fetch_task_path(task),
           params: { text: 'A short bio.' },
           headers: authorization_header
    end

    it 'saves a description sourced from the task' do
      expect { send_request }.to change(author.descriptions, :count).by(1)
      description = author.description_for_source(task)
      expect(description.text).to eq('A short bio.')
      expect(description.source_id).to eq(task.id)
      expect(response).to redirect_to(edit_admin_open_library_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('Author description updated.')
    end
  end

  describe 'POST /admin/open_library_author_fetch_tasks/:id/add_identity' do
    let(:send_request) do
      post add_identity_admin_open_library_author_fetch_task_path(task),
           params: { external_resource: 'wikidata', external_id: 'Q272076' },
           headers: authorization_header
    end

    it 'creates an identity and reloads the apply form' do
      expect { send_request }.to change(author.external_identities, :count).by(1)
      expect(response).to redirect_to(edit_admin_open_library_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('External identity added.')
    end
  end

  describe 'POST /admin/open_library_author_fetch_tasks/:id/add_link' do
    let(:send_request) do
      post add_link_admin_open_library_author_fetch_task_path(task),
           params: { external_resource: 'Homepage', url: 'http://www.deankoontz.com/' },
           headers: authorization_header
    end

    it 'creates an external link using the submitted label and reloads the apply form' do
      expect { send_request }.to change(ExternalLink, :count).by(1)
      link = ExternalLink.order(:id).last
      expect(link.owner).to eq(author)
      expect(link.external_resource).to eq('Homepage')
      expect(link.url).to eq('http://www.deankoontz.com/')
      expect(response).to redirect_to(edit_admin_open_library_author_fetch_task_path(task))
      expect(flash[:notice]).to eq('External link added.')
    end

    context 'when a link with the same URL already exists' do
      let!(:existing_link) do
        create(
          :external_link,
          owner: author,
          external_resource: 'Official Web Site',
          url: 'http://www.deankoontz.com/'
        )
      end

      it 'updates the existing link label' do
        expect { send_request }.not_to change(ExternalLink, :count)
        expect(existing_link.reload.external_resource).to eq('Homepage')
        expect(response).to redirect_to(edit_admin_open_library_author_fetch_task_path(task))
        expect(flash[:notice]).to eq('External link label updated.')
      end
    end
  end
end
