require 'rails_helper'

RSpec.describe Admin::FormsHelper do
  before do
    helper.extend(Admin::BooksHelper)
  end

  describe '#admin_literary_form_warning' do
    it 'warns for persisted and suggested values that are not predefined' do
      warning = helper.admin_literary_form_warning('audio_drama', 'short story', 'novel', 'audio_drama', nil)

      expect(warning).to include("Current value 'audio_drama' will be replaced!")
      expect(warning).to include("Current value 'short story' will be replaced!")
      expect(warning).not_to include('novel')
    end
  end

  describe '#admin_literary_form_select_tag' do
    it 'renders predefined options and omits an unknown selected value' do
      html = helper.admin_literary_form_select_tag('book[literary_form]', 'audio_drama')

      expect(html).to include('<option value="novel">Novel</option>')
      expect(html).to include('<option value=""')
      expect(html).not_to include('audio_drama')
      expect(html).not_to include('selected="selected"')
    end

    it 'selects a predefined value' do
      html = helper.admin_literary_form_select_tag('book[literary_form]', 'short')

      expect(html).to include('selected="selected" value="short"')
    end
  end

  describe '#authors_to_badges_entries' do
    let(:authors) { [build_stubbed(:author, fullname: 'AUTHOR_A')] }

    it 'returns the correct entries' do
      expect(helper.authors_to_badges_entries(authors)).to eq(
        [{ label: 'AUTHOR_A', id: authors[0].id }]
      )
    end
  end

  describe '#series_to_badges_entries' do
    let(:series_list) { [build_stubbed(:series, name: 'SERIES_A')] }

    it 'returns the correct entries' do
      expect(helper.series_to_badges_entries(series_list)).to eq(
        [{ label: 'SERIES_A', id: series_list[0].id }]
      )
    end
  end

  describe '#books_to_badges_entries' do
    let(:books) { [build_stubbed(:book, title: 'BOOK_A', year_published: 2020, authors: [author])] }
    let(:author) { build_stubbed(:author, fullname: 'AUTHOR_A') }

    it 'returns the correct entries' do
      expect(helper.books_to_badges_entries(books)).to eq(
        [{ label: 'BOOK_A by AUTHOR_A, 2020', id: books[0].id }]
      )
    end
  end

  describe '#descriptions_to_input_entries' do
    let(:descriptions) do
      [build_stubbed(:description, text: 'TEXT_A', source_label: 'SRC_A', priority: 2,
                                   source_type: 'Admin::Tasks::AiBookFetch', source_id: 15)]
    end

    it 'returns the correct entries' do
      expect(helper.descriptions_to_input_entries(descriptions)).to eq(
        [{
          id: descriptions[0].id,
          text: 'TEXT_A',
          source_label: 'SRC_A',
          display_source_label: 'SRC_A',
          priority: 2,
          source_type: 'Admin::Tasks::AiBookFetch',
          source_id: 15
        }]
      )
    end
  end
end
