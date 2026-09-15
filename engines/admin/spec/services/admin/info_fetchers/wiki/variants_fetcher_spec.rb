require 'rails_helper'

RSpec.describe Admin::InfoFetchers::Wiki::VariantsFetcher do
  describe '#fetch_variants' do
    subject(:call) { described_class.new.fetch_variants(page_name, locale) }

    let(:page_name) { 'Šimtas_metų_vienatvės' }
    let(:locale) { 'lt' }

    let(:expected_url) do
      'https://lt.wikipedia.org/w/api.php' \
        '?action=query&format=json&lllimit=500&prop=langlinks&titles=Šimtas_metų_vienatvės'
    end
    let(:service_api_response) do
      {
        'query' => {
          'pages' => {
            '123' => {
              'langlinks' => [
                { 'lang' => 'en', '*' => 'One_Hundred_Years_of_Solitude' },
                { 'lang' => 'be-tarask', '*' => 'Сто_гадоў_адзіноты' },
                { 'lang' => 'de', '*' => 'Hundert_Jahre_Einsamkeit' }
              ]
            }
          }
        }
      }
    end

    before do
      stub_request(:get, expected_url).to_return(status: 200, body: service_api_response.to_json)
    end

    it 'returns the original and required variants' do
      expect(call).to eq(
        'lt' => 'Šimtas_metų_vienatvės',
        'en' => 'One_Hundred_Years_of_Solitude'
      )
    end

    context 'when the service returns an error' do
      before do
        stub_request(:get, expected_url).to_return(status: 500)
      end

      it 'returns the original variant' do
        expect(call).to eq('lt' => 'Šimtas_metų_vienatvės')
      end
    end
  end
end
