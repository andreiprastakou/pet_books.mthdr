# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Wikidata::AuthorUsableValues do
  describe '.call' do
    subject(:result) { described_class.call(fetched_data) }

    let(:fetched_data) do
      {
        'statements' => {
          'P569' => [
            {
              'rank' => 'normal',
              'value' => {
                'type' => 'value',
                'content' => { 'time' => '+1977-03-04T00:00:00Z', 'precision' => 11 }
              }
            }
          ],
          'P570' => [
            {
              'rank' => 'normal',
              'value' => {
                'type' => 'value',
                'content' => { 'time' => '+2020-01-01T00:00:00Z', 'precision' => 11 }
              }
            }
          ],
          'P648' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'OL6761792A' } }
          ],
          'P2963' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => '2740668' } }
          ],
          'P7400' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'wellsdan' } }
          ],
          'P31' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q5' } }
          ],
          'P27' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q30' } }
          ],
          'P19' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q829' } }
          ],
          'P106' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q36180' } },
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q6625963' } }
          ],
          'P136' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q186424' } }
          ],
          'P166' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q1056237' } }
          ],
          'P1412' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q1860' } }
          ],
          'P18' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Dan Wells.jpg' } }
          ]
        },
        'sitelinks' => {
          'frwiki' => {
            'title' => 'Dan Wells',
            'badges' => [],
            'url' => 'https://fr.wikipedia.org/wiki/Dan_Wells'
          },
          'enwiki' => {
            'title' => 'Dan Wells (author)',
            'badges' => [],
            'url' => 'https://en.wikipedia.org/wiki/Dan_Wells_(author)'
          }
        }
      }
    end

    it 'returns readable author statement values and sitelinks with enwiki first' do
      expect(result).to eq(
        'date_of_birth' => '+1977-03-04T00:00:00Z',
        'date_of_death' => '+2020-01-01T00:00:00Z',
        'open_library_id' => 'OL6761792A',
        'goodreads_id' => '2740668',
        'librarything_id' => 'wellsdan',
        'instance_of' => ['Q5'],
        'countries' => ['Q30'],
        'place_of_birth' => ['Q829'],
        'occupations' => %w[Q36180 Q6625963],
        'genres' => ['Q186424'],
        'awards' => ['Q1056237'],
        'languages' => ['Q1860'],
        'image' => 'Dan Wells.jpg',
        'sitelinks' => [
          {
            'title' => 'Dan Wells (author)',
            'language' => 'en',
            'url' => 'https://en.wikipedia.org/wiki/Dan_Wells_(author)'
          },
          {
            'title' => 'Dan Wells',
            'language' => 'fr',
            'url' => 'https://fr.wikipedia.org/wiki/Dan_Wells'
          }
        ]
      )
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
        expect(result).to eq('goodreads_id' => '2740668')
      end
    end
  end
end
