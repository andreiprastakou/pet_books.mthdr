require 'rails_helper'

RSpec.describe Admin::InfoFetchers::Wikipedia::UrlParser do
  describe '.extract_base_name_and_locale' do
    subject(:call) { described_class.extract_base_name_and_locale(url) }

    let(:url) { 'https://en.wikipedia.org/wiki/Crime_and_Punishment' }

    it 'returns the base name and locale' do
      expect(call).to eq(%w[Crime_and_Punishment en])
    end

    context 'when the url is not a valid wikipedia url' do
      let(:url) { 'https://foobar.com' }

      it 'returns nils' do
        expect(call).to eq([nil, nil])
      end
    end
  end
end
