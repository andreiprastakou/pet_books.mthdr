# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Wikidata::BookUsableValues do
  describe '.call' do
    subject(:result) { described_class.call(fetched_data) }

    context 'with a lifelike Wikidata book fixture' do
      let(:fetched_data) do
        JSON.parse(
          File.read(
            Rails.root.join(
              'engines/admin/spec/fixtures/wikidata/book_fetch_tailored_realities.json'
            )
          )
        )
      end

      it 'extracts usable values in the book decision format' do
        expect(result).to eq(
          'authors' => ['Q457608'],
          'external_identities' => [
            { 'external_resource' => 'open_library', 'external_id' => 'OL42413123W' },
            { 'external_resource' => 'librarything', 'external_id' => '33363109' },
            { 'external_resource' => 'goodreads', 'external_id' => '87596585' }
          ],
          'publication_date' => '2025-12-09',
          'genres' => %w[Q132311 Q24925],
          'country_of_origin' => ['Q30'],
          'form_of_work' => 'Q1279564'
        )
      end
    end

    context 'when preferred ranks are present' do
      let(:fetched_data) do
        {
          'statements' => {
            'P50' => [
              { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q1' } },
              { 'rank' => 'preferred', 'value' => { 'type' => 'value', 'content' => 'Q2' } },
              { 'rank' => 'deprecated', 'value' => { 'type' => 'value', 'content' => 'Q3' } }
            ]
          }
        }
      end

      it 'uses preferred values and skips deprecated' do
        expect(result['authors']).to eq(['Q2'])
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
            'P648' => [
              { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'OL85742W' } }
            ]
          }
        }
      end

      it 'omits nil and empty values' do
        expect(result).to eq(
          'external_identities' => [
            { 'external_resource' => 'open_library', 'external_id' => 'OL85742W' }
          ]
        )
      end
    end

    context 'when publication date has year precision' do
      let(:fetched_data) do
        {
          'statements' => {
            'P577' => [
              {
                'rank' => 'normal',
                'value' => {
                  'type' => 'value',
                  'content' => { 'time' => '+1962-00-00T00:00:00Z', 'precision' => 9 }
                }
              }
            ]
          }
        }
      end

      it 'formats as a year' do
        expect(result).to eq('publication_date' => '1962')
      end
    end

    context 'when sitelinks are present' do
      let(:fetched_data) do
        {
          'statements' => {},
          'sitelinks' => {
            'hywiki' => {
              'title' => 'Լրտեսը, որն ինձ սիրում էր (վեպ)',
              'url' => 'https://hy.wikipedia.org/wiki/%D4%BC%D6%80%D5%BF%D5%A5%D5%BD%D5%A8'
            },
            'enwiki' => {
              'title' => 'The Spy Who Loved Me (novel)',
              'url' => 'https://en.wikipedia.org/wiki/The_Spy_Who_Loved_Me_(novel)'
            }
          }
        }
      end

      it 'returns sitelinks with enwiki first' do
        expect(result['sitelinks']).to eq(
          [
            {
              'title' => 'The Spy Who Loved Me (novel)',
              'language' => 'en',
              'url' => 'https://en.wikipedia.org/wiki/The_Spy_Who_Loved_Me_(novel)'
            },
            {
              'title' => 'Լրտեսը, որն ինձ սիրում էր (վեպ)',
              'language' => 'hy',
              'url' => 'https://hy.wikipedia.org/wiki/%D4%BC%D6%80%D5%BF%D5%A5%D5%BD%D5%A8'
            }
          ]
        )
      end
    end
  end
end
