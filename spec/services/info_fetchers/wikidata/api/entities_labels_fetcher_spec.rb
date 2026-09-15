# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InfoFetchers::Wikidata::Api::EntitiesLabelsFetcher do
  describe '#fetch' do
    subject(:result) { described_class.new.fetch(qids) }

    let(:qids) { %w[Q82104 Q47461344] }
    let(:expected_url) do
      'https://www.wikidata.org/w/api.php?' \
        'action=wbgetentities&format=json&ids=Q82104%7CQ47461344&languagefallback=1' \
        '&languages=en&props=labels%7Cdescriptions'
    end
    let(:service_api_response) do
      {
        'entities' => {
          'Q82104' => {
            'id' => 'Q82104',
            'labels' => { 'en' => { 'language' => 'en', 'value' => 'Ian Fleming' } },
            'descriptions' => { 'en' => { 'language' => 'en', 'value' => 'English author' } }
          },
          'Q47461344' => {
            'id' => 'Q47461344',
            'labels' => { 'en' => { 'language' => 'en', 'value' => 'written work' } },
            'descriptions' => {}
          }
        },
        'success' => 1
      }
    end

    before do
      allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
      stub_request(:get, expected_url)
        .with(headers: { 'User-Agent' => InfoFetchers::Wikidata::Api::BaseCaller::USER_AGENT })
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'returns labels and descriptions keyed by Q-ID' do
      expect(result).to eq(
        'Q82104' => { 'label' => 'Ian Fleming', 'description' => 'English author' },
        'Q47461344' => { 'label' => 'written work', 'description' => nil }
      )
    end

    context 'when qids are blank' do
      let(:qids) { [] }

      it 'does not call the API' do
        expect(result).to eq({})
        expect(a_request(:get, %r{wikidata\.org})).not_to have_been_made
      end
    end

    context 'when an entity is missing' do
      let(:qids) { ['Q1'] }
      let(:expected_url) do
        'https://www.wikidata.org/w/api.php?' \
          'action=wbgetentities&format=json&ids=Q1&languagefallback=1' \
          '&languages=en&props=labels%7Cdescriptions'
      end
      let(:service_api_response) do
        {
          'entities' => {
            'Q1' => { 'id' => 'Q1', 'missing' => '' }
          },
          'success' => 1
        }
      end

      it 'omits missing entities' do
        expect(result).to eq({})
      end
    end
  end
end
