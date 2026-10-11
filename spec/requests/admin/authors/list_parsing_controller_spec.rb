require 'rails_helper'

RSpec.describe Admin::Authors::ListParsingController do
  let(:author) { create(:author) }

  describe 'GET /admin/authors/:id/list_parsing/new' do
    let(:send_request) { get new_admin_author_list_parsing_path(author), headers: authorization_header }

    it 'renders the new template' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/authors/list_parsing/new'
    end
  end

  describe 'POST /admin/authors/:author_id/list_parsing' do
    let(:send_request) do
      post admin_author_list_parsing_index_path(author), params: params, headers: authorization_header
    end
    let(:params) { { text: "LINE_1\nLINE_2\nLINE_3" } }
    let(:task) { build_stubbed(:author_books_list_parsing_task, target: author) }

    before do
      allow(Admin::Tasks::AiAuthorWorksParse).to receive(:setup).with(author, text: params[:text]).and_return(task)
    end

    it 'creates a task and enqueues a job' do
      expect { send_request }.to have_enqueued_job(Admin::DataFetchJob).with(task.id)
    end

    it 'redirects to the author page' do
      send_request
      expect(response).to redirect_to(admin_author_path(author))
    end
  end

  describe 'GET /admin/authors/:author_id/list_parsing/:(task_)id/edit' do
    let(:send_request) { get edit_admin_author_list_parsing_path(author, task), headers: authorization_header }
    let(:task) do
      create(:author_books_list_parsing_task, target: author, fetched_data: fetched_data, status: :fetched)
    end
    let(:fetched_data) do
      [
        { 'title' => 'TITLE_1', 'year' => '2021', 'type' => 'TYPE_2' },
        { 'title' => 'TITLE_2_DIFFERENT', 'year' => '2022', 'type' => 'TYPE_2' },
        { 'title' => 'TITLE_3', 'year' => '2023', 'type' => 'TYPE_3' }
      ]
    end
    let(:books) do
      [
        create(:book, authors: [author], title: 'TITLE_1', year_published: '2020', literary_form: 'TYPE_1'),
        create(:book, authors: [author], title: 'TITLE_2', year_published: '2020', literary_form: 'TYPE_1')
      ]
    end

    before do
      books
    end

    it 'prepares and applies book updates and renders the edit template' do
      send_request
      expect(response).to be_successful
      expect(response).to render_template 'admin/authors/list_parsing/edit'
      expected_books = [
        [books[0].id, 'TITLE_1', 2021, 'TYPE_2'],
        [books[1].id, 'TITLE_2', 2020, 'TYPE_1'],
        [nil, 'TITLE_2_DIFFERENT', 2022, 'TYPE_2'],
        [nil, 'TITLE_3', 2023, 'TYPE_3']
      ]
      expect(assigns(:books).map { |b| [b.id, b.title, b.year_published, b.literary_form] }).to eq(expected_books)
      expect(response.body).to include("Current value 'TYPE_1' will be replaced!")
      expect(response.body).to include("Current value 'TYPE_2' will be replaced!")
      expect(response.body).to include("Current value 'TYPE_3' will be replaced!")
      expect(response.body).to include('<option value="novel">Novel</option>')
      expect(response.body).not_to include('<option value="TYPE_1"')
    end

    context 'when parsed books name series' do
      let(:fetched_data) do
        [
          { 'title' => 'TITLE_1', 'year' => '2021', 'type' => 'novel', 'series' => 'KNOWN_SERIES' },
          { 'title' => 'TITLE_NEW', 'year' => '2024', 'type' => 'novel', 'series' => 'NEW_SERIES' },
          { 'title' => 'TITLE_KNOWN', 'year' => '2024', 'type' => 'novel', 'series' => known_series.name }
        ]
      end
      let(:known_series) { create(:series, name: 'KNOWN_SERIES') }
      let(:books) { [create(:book, authors: [author], title: 'TITLE_1', series: [known_series])] }

      it 'preselects series without creating missing ones' do
        known_series
        expect { send_request }.not_to change(Series, :count)

        existing_book = assigns(:books).find { |book| book.title == 'TITLE_1' }
        new_book = assigns(:books).find { |book| book.title == 'TITLE_NEW' }
        known_book = assigns(:books).find { |book| book.title == 'TITLE_KNOWN' }

        expect(existing_book.preselected_series).to be_blank
        expect(new_book.preselected_series.map { |series| [series.name, series.id] }).to eq([['NEW_SERIES', nil]])
        expect(known_book.preselected_series.map { |series| [series.name, series.id] }).to eq(
          [[known_series.name, known_series.id]]
        )

        new_series_json = ERB::Util.html_escape([{ label: 'NEW_SERIES', id: nil }].to_json)
        known_series_json = ERB::Util.html_escape([{ label: known_series.name, id: known_series.id }].to_json)
        expect(response.body).to include(%(data-values="#{new_series_json}"))
        expect(response.body).to include(%(data-values="#{known_series_json}"))
        expect(response.body).to include(%(data-old-values="#{known_series_json}"))
      end
    end
  end

  describe 'POST /admin/authors/:author_id/list_parsing/:(task_)id/apply' do
    let(:send_request) do
      post apply_admin_author_list_parsing_path(author, task), params: params, headers: authorization_header
    end
    let(:task) { create(:author_books_list_parsing_task, target: author, status: :fetched, fetched_data: fetched_data) }
    let(:fetched_data) do
      [{ 'title' => 'TITLE_1', 'year' => '2021', 'type' => 'TYPE_2' }]
    end
    let(:params) do
      {
        batch: {
          '0' => { id: book.id, title: 'TITLE_1', year: '2025', type: 'TYPE_2' }
        }
      }
    end
    let(:book) { build_stubbed(:book) }
    let(:updater) { instance_double(Admin::BooksBatchUpdater) }

    before do
      book
      allow(Admin::BooksBatchUpdater).to receive(:new).and_return(updater)
      allow(updater).to receive_messages(update: true, books: [book])
    end

    it 'updates books via the updater' do
      send_request
      expect(updater).to have_received(:update)
      expect(assigns(:books)).to contain_exactly(book)
    end

    it 'marks the task as verified' do
      send_request
      expect(task.reload).to be_verified
    end

    it 'redirects to the apply form' do
      send_request
      expect(response).to redirect_to(edit_admin_author_list_parsing_path(author, task))
      expect(flash[:notice]).to eq('Updates applied.')
    end

    context 'with invalid params' do
      before do
        allow(updater).to receive_messages(update: false, collect_errors: 'Title cannot be blank')
      end

      it 'renders the edit template again' do
        send_request
        expect(response).to render_template 'admin/authors/list_parsing/edit'
        expect(flash[:error]).to include('Title cannot be blank')
      end
    end
  end
end
