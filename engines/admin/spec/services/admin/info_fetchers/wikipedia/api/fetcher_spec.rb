# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::InfoFetchers::Wikipedia::Api::Fetcher do
  let(:fetcher) { described_class.new }
  let(:user_agent) { described_class::USER_AGENT }

  before do
    allow(Admin::ExternalApiRateLimit).to receive(:throttle!)
  end

  describe '#fetch' do
    subject(:result) { fetcher.fetch(params) }

    let(:params) do
      {
        action: 'query',
        prop: 'extracts',
        exintro: 1,
        explaintext: 1,
        titles: 'Tress of the Emerald Sea'
      }
    end
    let(:service_api_response) do
      {
        'batchcomplete' => true,
        'query' => {
          'pages' => [
            {
              'pageid' => 73_617_124,
              'ns' => 0,
              'title' => 'Tress of the Emerald Sea',
              'extract' => 'Tress of the Emerald Sea is an epic fantasy novel.'
            }
          ]
        }
      }
    end

    before do
      stub_request(:get, 'https://en.wikipedia.org/w/api.php')
        .with(
          query: hash_including(
            'action' => 'query',
            'prop' => 'extracts',
            'exintro' => '1',
            'explaintext' => '1',
            'titles' => 'Tress of the Emerald Sea',
            'format' => 'json',
            'formatversion' => '2'
          ),
          headers: { 'User-Agent' => user_agent }
        )
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'fetches JSON from the Action API' do
      expect(result).to eq(service_api_response)
    end

    context 'when a non-default language is given' do
      let(:fetcher) { described_class.new(language: 'sk') }

      before do
        stub_request(:get, 'https://sk.wikipedia.org/w/api.php')
          .with(
            query: hash_including('action' => 'query', 'format' => 'json'),
            headers: { 'User-Agent' => user_agent }
          )
          .to_return(status: 200, body: { 'batchcomplete' => true }.to_json)
      end

      it 'uses that language subdomain' do
        expect(fetcher.fetch(action: 'query', titles: 'Test')).to eq('batchcomplete' => true)
      end
    end

    context 'when the service returns an error' do
      before do
        stub_request(:get, 'https://en.wikipedia.org/w/api.php')
          .with(query: hash_including('action' => 'query'))
          .to_return(status: 500)
      end

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '#fetch_intro' do
    subject(:result) { fetcher.fetch_intro(title) }

    let(:title) { 'Tress of the Emerald Sea' }
    let(:service_api_response) do
      {
        'query' => {
          'pages' => [
            { 'title' => title, 'extract' => 'An epic fantasy novel.' }
          ]
        }
      }
    end

    before do
      stub_request(:get, 'https://en.wikipedia.org/w/api.php')
        .with(
          query: hash_including(
            'action' => 'query',
            'prop' => 'extracts',
            'exintro' => '1',
            'explaintext' => '1',
            'titles' => title
          ),
          headers: { 'User-Agent' => user_agent }
        )
        .to_return(status: 200, body: service_api_response.to_json)
    end

    it 'requests a plain-text lead extract' do
      expect(result).to eq(service_api_response)
    end

    context 'when the title is blank' do
      let(:title) { '  ' }

      it 'does not call the API and returns nil' do
        expect(result).to be_nil
        expect(a_request(:get, /wikipedia\.org/)).not_to have_been_made
      end
    end
  end
end
