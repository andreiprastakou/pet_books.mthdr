require 'rails_helper'

RSpec.describe Admin::InfoFetchers::Wikipedia::ViewsFetcher do
  describe '#fetch' do
    subject(:call) { described_class.new.fetch(page_name, locale, **options) }

    let(:page_name) { 'Crime_and_Punishment' }
    let(:locale) { 'en' }
    let(:options) { {} }

    let(:expected_url) do
      'https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/en.wikipedia.org/all-access/user' \
        '/Crime_and_Punishment/monthly/20230413/20240413'
    end
    let(:service_api_response) do
      {
        'items' => [
          { 'timestamp' => '2024010100', 'views' => 101 },
          { 'timestamp' => '2024020100', 'views' => 103 },
          { 'timestamp' => '2024030100', 'views' => 107 },
          { 'timestamp' => '2024040100', 'views' => 19 }
        ]
      }
    end

    around do |example|
      Timecop.freeze(DateTime.parse('2024-04-13 01:02:03')) do
        example.run
      end
    end

    before do
      stub_request(:get, expected_url).to_return(status: 200, body: service_api_response.to_json)
    end

    it 'returns the views' do
      expect(call).to eq([101 + 103 + 107 + 19, 19])
    end

    context 'when the service returns an error' do
      before do
        stub_request(:get, expected_url).to_return(status: 500)
      end

      it 'returns nil' do
        expect(call).to be_nil
      end
    end

    context 'when the last synced at is provided' do
      let(:options) { { last_synced_at: DateTime.parse('2024-02-02 01:02:03 UTC') } }

      let(:expected_url) do
        'https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/en.wikipedia.org/all-access/user' \
          '/Crime_and_Punishment/monthly/20240202/20240413'
      end

      it 'queries with given timestamp and skips irrelevant stats' do
        expect(call).to eq([103 + 107 + 19, 19])
      end

      context 'when the last synced at is later than 2 months ago' do
        let(:options) { { last_synced_at: DateTime.parse('2024-04-10 01:02:03 UTC') } }

        let(:expected_url) do
          'https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/en.wikipedia.org/all-access/user' \
            '/Crime_and_Punishment/monthly/20240213/20240413'
        end

        it 'queries with 2 months ago but returns only the last month' do
          expect(call).to eq([19, 19])
        end
      end
    end
  end
end
