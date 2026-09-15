# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Wikidata::BookUsableValues do
  describe '.call' do
    subject(:result) { described_class.call(fetched_data) }

    let(:fetched_data) do
      {
        'statements' => {
          'P50' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q82104' } }
          ],
          'P648' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'OL85742W' } }
          ],
          'P1085' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => '38539' } }
          ],
          'P8383' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => '375802' } }
          ],
          'P2034' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => '12345' } }
          ],
          'P577' => [
            {
              'rank' => 'normal',
              'value' => {
                'type' => 'value',
                'content' => {
                  'time' => '+1962-00-00T00:00:00Z',
                  'precision' => 9
                }
              }
            }
          ],
          'P31' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q47461344' } }
          ],
          'P179' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q844' } }
          ],
          'P136' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q20664331' } },
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q5937792' } }
          ],
          'P166' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q103360' } }
          ],
          'P495' => [
            { 'rank' => 'normal', 'value' => { 'type' => 'value', 'content' => 'Q145' } }
          ]
        },
        'sitelinks' => {
          'hywiki' => {
            'title' => 'Լրտեսը, որն ինձ սիրում էր (վեպ)',
            'badges' => [],
            'url' => 'https://hy.wikipedia.org/wiki/%D4%BC%D6%80%D5%BF%D5%A5%D5%BD%D5%A8'
          },
          'enwiki' => {
            'title' => 'The Spy Who Loved Me (novel)',
            'badges' => ['Q17437796'],
            'url' => 'https://en.wikipedia.org/wiki/The_Spy_Who_Loved_Me_(novel)'
          },
          'frwiki' => {
            'title' => 'Motel 007',
            'badges' => [],
            'url' => 'https://fr.wikipedia.org/wiki/Motel_007'
          }
        }
      }
    end

    it 'returns readable statement values and sitelinks with enwiki first' do
      expect(result).to eq(
        'authors' => ['Q82104'],
        'open_library_id' => 'OL85742W',
        'librarything_id' => '38539',
        'goodreads_id' => '375802',
        'gutenberg_id' => '12345',
        'publication_date' => '+1962-00-00T00:00:00Z',
        'instance_of' => ['Q47461344'],
        'series' => ['Q844'],
        'genres' => %w[Q20664331 Q5937792],
        'awards' => ['Q103360'],
        'country_of_origin' => ['Q145'],
        'sitelinks' => [
          {
            'title' => 'The Spy Who Loved Me (novel)',
            'language' => 'en',
            'url' => 'https://en.wikipedia.org/wiki/The_Spy_Who_Loved_Me_(novel)'
          },
          {
            'title' => 'Լրտեսը, որն ինձ սիրում էր (վեպ)',
            'language' => 'hy',
            'url' => 'https://hy.wikipedia.org/wiki/%D4%BC%D6%80%D5%BF%D5%A5%D5%BD%D5%A8'
          },
          {
            'title' => 'Motel 007',
            'language' => 'fr',
            'url' => 'https://fr.wikipedia.org/wiki/Motel_007'
          }
        ]
      )
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
        expect(result).to eq('open_library_id' => 'OL85742W')
      end
    end
  end
end
