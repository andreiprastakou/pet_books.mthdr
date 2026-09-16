require 'rails_helper'

RSpec.describe Admin::DataFetchTasksController do
  describe 'GET /admin/data_fetch_tasks' do
    let(:send_request) { get admin_data_fetch_tasks_path, headers: authorization_header }
    let(:tasks) { create_list(:book_summary_task, 3) }

    before { tasks }

    it 'returns a successful response' do
      send_request
      expect(response).to be_successful
      expect(assigns(:tasks)).to match_array(tasks)
      expect(assigns(:pagy)).to be_present
    end

    context 'when filtering by type' do
      let!(:summary_task) { create(:book_summary_task) }
      let!(:search_task) { create(:open_library_search_task) }
      let(:send_request) do
        get admin_data_fetch_tasks_path,
            params: { type: 'Admin::Tasks::AiBookFetch' },
            headers: authorization_header
      end

      it 'returns only matching task types' do
        send_request
        expect(response).to be_successful
        expect(assigns(:tasks)).to include(summary_task)
        expect(assigns(:tasks)).not_to include(search_task)
      end
    end

    context 'when filtering by status' do
      let!(:fetched_task) { create(:book_summary_task, status: :fetched) }
      let!(:failed_task) { create(:book_summary_task, status: :failed) }
      let(:send_request) do
        get admin_data_fetch_tasks_path,
            params: { status: 'fetched' },
            headers: authorization_header
      end

      it 'returns only matching statuses' do
        send_request
        expect(response).to be_successful
        expect(assigns(:tasks)).to include(fetched_task)
        expect(assigns(:tasks)).not_to include(failed_task)
      end
    end
  end


  describe 'GET /admin/data_fetch_tasks/:id' do
    let(:send_request) { get admin_data_fetch_task_path(task), headers: authorization_header }
    let(:task) { create(:book_summary_task) }

    it 'returns a successful response' do
      send_request
      expect(response).to be_successful
      expect(assigns(:task)).to eq(task)
    end

    context 'with an OpenLibraryBookSearch' do
      let(:task) { create(:open_library_search_task, status: :fetched, fetched_data: []) }

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_open_library_book_search')
      end
    end

    context 'with an OpenLibraryBookFetch' do
      let(:task) { create(:open_library_fetch_task, status: :fetched, fetched_data: { 'title' => 'X' }) }

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_open_library_book_fetch')
      end
    end

    context 'with a WikidataBookFetch' do
      let(:task) do
        create(
          :wikidata_fetch_task,
          status: :fetched,
          fetched_data: {
            'id' => 'Q74287',
            'labels' => { 'en' => 'The Hobbit' },
            'statements' => {
              'P648' => [
                { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'OL27482W' } }
              ]
            },
            'sitelinks' => {
              'enwiki' => {
                'title' => 'The Hobbit',
                'url' => 'https://en.wikipedia.org/wiki/The_Hobbit'
              }
            }
          }
        )
      end

      it 'returns a successful response with usable values' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikidata_book_fetch')
        expect(response.body).to include('open_library')
        expect(response.body).to include('OL27482W')
        expect(response.body).to include('en.wikipedia.org')
      end
    end

    context 'with a WikidataAuthorFetch' do
      let(:author) { create(:author) }
      let(:external_identity) do
        create(:external_identity, owner: author, external_resource: :wikidata, external_id: 'Q892')
      end
      let(:task) do
        create(
          :wikidata_author_fetch_task,
          target: external_identity,
          status: :fetched,
          fetched_data: {
            'labels' => { 'en' => 'J. R. R. Tolkien' },
            'statements' => {
              'P2963' => [
                { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => '2740668' } }
              ]
            }
          }
        )
      end

      it 'returns a successful response with usable values' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikidata_author_fetch')
        expect(response.body).to include('goodreads')
        expect(response.body).to include('2740668')
      end
    end

    context 'with a WikidataBookSearch' do
      let(:task) do
        create(
          :wikidata_search_task,
          status: :fetched,
          fetched_data: [
            {
              'id' => 'Q320423',
              'display-label' => { 'language' => 'en', 'value' => 'The Spy Who Loved Me' },
              'description' => { 'language' => 'en', 'value' => '1977 film' }
            }
          ]
        )
      end

      it 'returns a successful response with usable values' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikidata_book_search')
        expect(response.body).to include('Q320423')
        expect(response.body).to include('The Spy Who Loved Me')
      end
    end

    context 'with a WikidataAuthorSearch' do
      let(:task) do
        create(
          :wikidata_author_search_task,
          status: :fetched,
          fetched_data: [
            {
              'id' => 'Q892',
              'display-label' => { 'language' => 'en', 'value' => 'J. R. R. Tolkien' },
              'description' => { 'language' => 'en', 'value' => 'English writer' }
            }
          ]
        )
      end

      it 'returns a successful response with usable values' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikidata_author_search')
        expect(response.body).to include('Q892')
        expect(response.body).to include('J. R. R. Tolkien')
      end
    end

    context 'with a WikipediaBookFetch' do
      let(:book) { create(:book, wiki_url: 'https://en.wikipedia.org/wiki/Medea_(Seneca)') }
      let(:task) do
        create(
          :wikipedia_book_fetch_task,
          target: book,
          status: :fetched,
          fetched_data: {
            'query' => {
              'pages' => [
                {
                  'title' => 'Medea (Seneca)',
                  'extract' => 'Medea is a fabula crepidata written by Seneca the Younger.'
                }
              ]
            }
          }
        )
      end

      it 'returns a successful response with normalized description' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikipedia_book_fetch')
        expect(response.body).to include('description')
        expect(response.body).to include('fabula crepidata')
      end
    end

    context 'with a WikipediaAuthorFetch' do
      let(:author) { create(:author, wiki_url: 'https://en.wikipedia.org/wiki/Seneca') }
      let(:task) do
        create(
          :wikipedia_author_fetch_task,
          target: author,
          status: :fetched,
          fetched_data: {
            'query' => {
              'pages' => [
                { 'title' => 'Seneca', 'extract' => 'A Roman Stoic philosopher.' }
              ]
            }
          }
        )
      end

      it 'returns a successful response with normalized description' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikipedia_author_fetch')
        expect(response.body).to include('description')
        expect(response.body).to include('Roman Stoic philosopher')
      end
    end

    context 'when the type-specific partial is missing' do
      let(:task) { create(:library_thing_search_task, status: :fetched, fetched_data: {}) }

      it 'falls back to the shared task info card' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/_task_info_card')
        expect(response).not_to render_template('admin/data_fetch_tasks/types/_library_thing_book_search')
      end
    end

    context 'when the task is fetched' do
      let(:task) { create(:open_library_search_task, status: :fetched, fetched_data: []) }

      it 'renders verify and reject buttons' do
        send_request
        expect(response.body).to include('mark as verified')
        expect(response.body).to include('mark as rejected')
      end
    end
  end

  describe 'PUT /admin/data_fetch_tasks/:id/verify' do
    let(:task) { create(:open_library_search_task, status: :fetched) }
    let(:send_request) { put verify_admin_data_fetch_task_path(task), headers: authorization_header }

    it 'marks the task verified and redirects home' do
      send_request
      expect(task.reload.status).to eq('verified')
      expect(response).to redirect_to(admin_root_path)
      expect(flash[:notice]).to eq("Task ID=#{task.id} marked as verified")
    end
  end

  describe 'PUT /admin/data_fetch_tasks/:id/reject' do
    let(:task) { create(:open_library_search_task, status: :fetched) }
    let(:send_request) { put reject_admin_data_fetch_task_path(task), headers: authorization_header }

    it 'marks the task rejected and redirects home' do
      send_request
      expect(task.reload.status).to eq('rejected')
      expect(response).to redirect_to(admin_root_path)
      expect(flash[:notice]).to eq("Task ID=#{task.id} marked as rejected")
    end
  end
end
