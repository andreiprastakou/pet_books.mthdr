require 'rails_helper'

RSpec.describe Admin::Series::BooksBatchController do
  let(:author) { create(:author, fullname: 'Title Author') }
  let(:series) { create(:series, name: 'Discworld') }
  let(:included_work) { create(:book, title: 'Included Work', authors: [author], year_published: 1990) }

  describe 'GET /admin/series/:series_id/books_batch/edit' do
    let(:send_request) { get edit_admin_series_books_batch_path(series), headers: authorization_header }

    before do
      create(:external_link, owner: series, url: 'https://example.com/series')
      create(:book_series, series: series, book: included_work)
      create(:book, title: 'Unrelated Work', authors: [author])
    end

    it 'renders the series books batch edit page' do
      send_request

      expect(response).to be_successful
      expect(response).to render_template 'admin/series/books_batch/edit'
      expect(response.body).to include('Books Batch Edit')
      expect(response.body).to include('title="Skip"')

      references = response.body[/Parental references.*?Books to update:/m]
      expect(references).to include('https://example.com/series')
      expect(references).not_to include('Discworld')
      expect(references).not_to include('Included Work')

      expect(response.body).to include('Included Work')
      expect(response.body).not_to include('Unrelated Work')
    end

    it 'prefills new rows with the series and asks autocomplete rows to include it' do
      send_request

      series_json = ERB::Util.html_escape([{ label: 'Discworld', id: series.id }].to_json)
      expect(response.body).to match(
        /data-values="#{Regexp.escape(series_json)}"\s+data-old-values="\[\]"[\s\S]*?batch\[ENTRY_INDEX\]\[series_ids\]/
      )
      expect(response.body).to include("ensure_series_id=#{series.id}")
      expect(response.body).to include(
        'name="batch[ENTRY_INDEX][literary_form]" id="batch_ENTRY_INDEX_literary_form" ' \
        'class="form-select form-select-sm"'
      )
      expect(response.body).to include('<option value="novel">Novel</option>')
      expect(response.body).not_to include('type="text" name="batch[ENTRY_INDEX][literary_form]"')
      expect(response.body).to include(
        '<input type="text" name="batch[ENTRY_INDEX][year_published]" id="batch_ENTRY_INDEX_year_published" ' \
        'class="form-control form-control-sm" />'
      )
      expect(response.body).to match(
        /data-values="\[\]"\s+data-old-values="\[\]"[\s\S]*?batch\[ENTRY_INDEX\]\[author_ids\]/
      )
    end
  end

  describe 'PUT /admin/series/:series_id/books_batch' do
    let(:send_request) { put admin_series_books_batch_path(series), params: params, headers: authorization_header }

    before { create(:book_series, series: series, book: included_work) }

    context 'when adding a new work' do
      let(:params) do
        {
          batch: {
            0 => {
              id: included_work.id,
              title: included_work.title,
              year_published: included_work.year_published,
              author_ids: [author.id],
              series_ids: [series.id]
            },
            1 => {
              title: 'New Series Work',
              literary_form: 'novel',
              year_published: 2024,
              author_ids: [author.id]
            }
          }
        }
      end

      it 'does not add the series unless the form submits it' do
        expect { send_request }.not_to change(Joins::BookSeries, :count)

        new_work = Admin::Book.find_by!(title: 'New Series Work')
        expect(new_work.series).to be_empty
        expect(series.reload.books).to contain_exactly(included_work)
        expect(response).to redirect_to admin_series_path(series)
      end
    end

    context 'when updating an included work' do
      let(:params) do
        {
          batch: {
            0 => {
              id: included_work.id,
              title: 'Renamed Work',
              year_published: included_work.year_published,
              author_ids: [author.id],
              series_ids: [series.id]
            }
          }
        }
      end

      it 'updates the work without adding another series link' do
        expect { send_request }.not_to change(Joins::BookSeries, :count)
        expect(included_work.reload.title).to eq 'Renamed Work'
        expect(response).to redirect_to admin_series_path(series)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          batch: {
            0 => {
              title: '',
              year_published: 2024,
              author_ids: [author.id]
            }
          }
        }
      end

      it 'renders the form again without creating a work' do
        expect { send_request }.not_to change(Book, :count)
        expect(response).to render_template 'admin/series/books_batch/edit'
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:error]).to include("Title can't be blank")
      end
    end
  end
end
