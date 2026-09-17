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

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikidata_book_fetch')
        expect(response.body).to include(edit_admin_wikidata_book_fetch_task_path(task))
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

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikidata_author_fetch')
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
        expect(response.body).to include('task_apply_form')
        expect(response.body).to include(edit_admin_wikidata_book_search_task_path(task))
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
        expect(response.body).to include('task_apply_form')
        expect(response.body).to include(edit_admin_wikidata_author_search_task_path(task))
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

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikipedia_book_fetch')
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

      it 'returns a successful response' do
        send_request
        expect(response).to be_successful
        expect(response).to render_template('admin/data_fetch_tasks/types/_wikipedia_author_fetch')
      end
    end

    context 'when the type-specific partial is missing' do
      let(:task) { create(:library_thing_search_task, status: :fetched, fetched_data: {}) }

      before do
        allow_any_instance_of(ActionView::LookupContext).to receive(:exists?)
          .and_call_original
        allow_any_instance_of(ActionView::LookupContext).to receive(:exists?)
          .with('library_thing_book_search', 'admin/data_fetch_tasks/types', true)
          .and_return(false)
      end

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
    let(:book) { create(:book) }
    let(:task) { create(:open_library_search_task, target: book, status: :fetched) }
    let(:send_request) { put verify_admin_data_fetch_task_path(task), headers: authorization_header }

    it 'marks the task verified and redirects to the target book when no next review task exists' do
      send_request
      expect(task.reload.status).to eq('verified')
      expect(response).to redirect_to(admin_book_path(book))
      expect(flash[:notice]).to eq("Task ID=#{task.id} marked as verified")
    end

    context 'when another fetched task exists for the same book' do
      let!(:next_task) { create(:wikipedia_book_fetch_task, target: book, status: :fetched) }

      it 'redirects to the highest-priority pending review task' do
        send_request
        expect(task.reload.status).to eq('verified')
        expect(response).to redirect_to(admin_data_fetch_task_path(next_task))
      end
    end

    context 'when the task targets an external identity owned by a book' do
      let(:identity) do
        create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
      end
      let(:task) { create(:wikidata_fetch_task, target: identity, status: :fetched) }
      let!(:next_task) { create(:open_library_search_task, target: book, status: :fetched) }

      it 'redirects to the next pending review task for the owner book' do
        send_request
        expect(response).to redirect_to(admin_data_fetch_task_path(next_task))
      end
    end
  end

  describe 'PUT /admin/data_fetch_tasks/:id/reject' do
    let(:author) { create(:author) }
    let(:task) { create(:wikidata_author_search_task, target: author, status: :fetched) }
    let(:send_request) { put reject_admin_data_fetch_task_path(task), headers: authorization_header }

    it 'marks the task rejected and redirects to the target author when no next review task exists' do
      send_request
      expect(task.reload.status).to eq('rejected')
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:notice]).to eq("Task ID=#{task.id} marked as rejected")
    end

    context 'when another fetched task exists for the same author' do
      let!(:next_task) { create(:wikipedia_author_fetch_task, target: author, status: :fetched) }

      it 'redirects to the highest-priority pending review task' do
        send_request
        expect(task.reload.status).to eq('rejected')
        expect(response).to redirect_to(admin_data_fetch_task_path(next_task))
      end
    end
  end
end
