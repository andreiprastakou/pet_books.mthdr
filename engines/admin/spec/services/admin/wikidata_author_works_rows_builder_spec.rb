# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WikidataAuthorWorksRowsBuilder do
  subject(:rows) { described_class.call(author: author, works: works) }

  let(:author) { create(:author) }

  describe '#call' do
    context 'when combining books and works' do
      let!(:early_book) { create(:book, authors: [author], title: 'Early', year_published: 1901) }
      let!(:matched_by_id) { create(:book, authors: [author], title: 'Old Title', year_published: 1950) }
      let!(:matched_by_title) { create(:book, authors: [author], title: 'Shared Title', year_published: 1970) }
      let!(:late_book) { create(:book, authors: [author], title: 'Late', year_published: 2000) }
      let(:works) do
        [
          {
            'work' => 'Q100',
            'work_label' => 'New Title',
            'publication_date' => '1955-01-01T00:00:00Z',
            'type_label' => 'novel'
          },
          {
            'work' => 'Q200',
            'work_label' => 'Shared Title',
            'publication_date' => '1975-06-01T00:00:00Z',
            'type_label' => 'novella'
          },
          {
            'work' => 'Q300',
            'work_label' => 'Unmatched Work',
            'publication_date' => '1960-01-01T00:00:00Z',
            'type_label' => 'short story'
          }
        ]
      end

      before do
        create(:external_identity, owner: matched_by_id, external_resource: :wikidata, external_id: 'Q100')
      end

      it 'returns rows sorted by year ascending with expected matches' do
        expect(rows.map { |row| [row.book&.id, row.wikidata_id, row.year.to_i] }).to eq(
          [
            [early_book.id, nil, 1901],
            [matched_by_id.id, 'Q100', 1955],
            [nil, 'Q300', 1960],
            [matched_by_title.id, 'Q200', 1975],
            [late_book.id, nil, 2000]
          ]
        )
      end

      it 'presets wikidata values and keeps book values as old values for matches', :aggregate_failures do
        id_row = rows.find { |row| row.wikidata_id == 'Q100' }
        expect(id_row.title).to eq('New Title')
        expect(id_row.old_title).to eq('Old Title')
        expect(id_row.year).to eq(1955)
        expect(id_row.old_year).to eq(1950)
        expect(id_row.work_type).to eq('novel')

        title_row = rows.find { |row| row.wikidata_id == 'Q200' }
        expect(title_row.title).to eq('Shared Title')
        expect(title_row.old_title).to eq('Shared Title')
        expect(title_row.year).to eq(1975)
        expect(title_row.old_year).to eq(1970)
        expect(title_row.work_type).to eq('novella')
      end

      it 'lists unmatched books without a work type' do
        book_only = rows.find { |row| row.book == early_book }
        expect(book_only.work_type).to be_nil
        expect(book_only.wikidata_id).to be_nil
        expect(book_only.work).to be_nil
      end

      it 'lists unmatched works without a book id' do
        work_only = rows.find { |row| row.wikidata_id == 'Q300' }
        expect(work_only.book).to be_nil
        expect(work_only.title).to eq('Unmatched Work')
        expect(work_only.work_type).to eq('short story')
      end

      it 'marks wikidata ids as new when the book did not already have them' do
        expect(rows.find { |row| row.wikidata_id == 'Q100' }.new_wikidata_id).to be(false)
        expect(rows.find { |row| row.wikidata_id == 'Q200' }.new_wikidata_id).to be(true)
        expect(rows.find { |row| row.wikidata_id == 'Q300' }.new_wikidata_id).to be(true)
      end
    end

    context 'when a title match is reserved by an external_id match' do
      let!(:book) { create(:book, authors: [author], title: 'Same Title', year_published: 1980) }
      let(:works) do
        [
          {
            'work' => 'Q1',
            'work_label' => 'Other Label',
            'publication_date' => '1981-01-01T00:00:00Z',
            'type_label' => 'novel'
          },
          {
            'work' => 'Q2',
            'work_label' => 'Same Title',
            'publication_date' => '1982-01-01T00:00:00Z',
            'type_label' => 'novella'
          }
        ]
      end

      before do
        create(:external_identity, owner: book, external_resource: :wikidata, external_id: 'Q1')
      end

      it 'keeps the reserved title-matched work as a form without a book' do
        expect(rows.size).to eq(2)
        matched = rows.find { |row| row.wikidata_id == 'Q1' }
        expect(matched.book).to eq(book)

        reserved = rows.find { |row| row.wikidata_id == 'Q2' }
        expect(reserved.book).to be_nil
        expect(reserved.title).to eq('Same Title')
      end
    end
  end
end
