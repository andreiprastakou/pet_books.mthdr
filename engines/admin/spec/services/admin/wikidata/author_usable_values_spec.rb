# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Wikidata::AuthorUsableValues do
  describe '.call' do
    subject(:result) { described_class.call(fetched_data) }

    context 'with a lifelike Wikidata author fixture' do
      let(:fetched_data) do
        JSON.parse(
          File.read(
            Rails.root.join(
              'engines/admin/spec/fixtures/wikidata/author_fetch_robert_jordan.json'
            )
          )
        )
      end

      it 'extracts usable values in the author decision format' do
        expect(result.except('sitelinks')).to eq(
          'name' => 'Robert Jordan',
          'date_of_birth' => '1948-10-17',
          'date_of_death' => '2007-09-16',
          'image' => 'Robert Jordan.jpg',
          'countries' => ['Q30'],
          'languages' => ['Q1860'],
          'awards' => %w[Q1754110 Q928314 Q2687578],
          'external_identities' => [
            { 'external_resource' => 'open_library', 'external_id' => 'OL233594A' },
            { 'external_resource' => 'goodreads', 'external_id' => '6252' },
            { 'external_resource' => 'librarything', 'external_id' => 'jordanrobert-1' }
          ]
        )
        expect(result['sitelinks'].size).to eq(44)
        expect(result['sitelinks'].first).to eq(
          'title' => 'Robert Jordan',
          'language' => 'en',
          'url' => 'https://en.wikipedia.org/wiki/Robert_Jordan'
        )
      end
    end

    context 'when fetched_data is blank' do
      let(:fetched_data) { nil }

      it 'returns an empty hash' do
        expect(result).to eq({})
      end
    end

    context 'when only some fields are present' do
      let(:fetched_data) do
        {
          'statements' => {
            'P2963' => [
              { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => '2740668' } }
            ]
          }
        }
      end

      it 'omits nil and empty values' do
        expect(result).to eq(
          'external_identities' => [
            { 'external_resource' => 'goodreads', 'external_id' => '2740668' }
          ]
        )
      end
    end

    context 'when English label is missing' do
      let(:fetched_data) do
        {
          'labels' => {
            'fr' => 'Robert Jordan',
            'de' => 'Robert Jordan'
          }
        }
      end

      it 'uses the first available label' do
        expect(result).to eq('name' => 'Robert Jordan')
      end
    end
  end
end
