# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalLinks::Wikidata do
  describe '.normalize_id' do
    {
      'Q137179018' => 'Q137179018',
      '/wiki/Q137179018' => 'Q137179018',
      'https://www.wikidata.org/wiki/Q137179018' => 'Q137179018',
      'https://www.wikidata.org/w/rest.php/wikibase/v1/entities/items/Q137179018' => 'Q137179018'
    }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected.inspect}" do
        expect(described_class.normalize_id(input)).to eq(expected)
      end
    end

    it 'returns nil for blank or invalid values' do
      expect(described_class.normalize_id(nil)).to be_nil
      expect(described_class.normalize_id('')).to be_nil
      expect(described_class.normalize_id('not-a-qid')).to be_nil
    end
  end

  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      'Q137179018' => 'https://www.wikidata.org/wiki/Q137179018',
      '/wiki/Q137179018' => 'https://www.wikidata.org/wiki/Q137179018',
      'https://www.wikidata.org/wiki/Q137179018' => 'https://www.wikidata.org/wiki/Q137179018'
    }.each do |input, expected|
      context "with #{input.inspect}" do
        let(:identificator) { input }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with a blank identificator' do
      let(:identificator) { '' }

      it { is_expected.to be_nil }
    end
  end
end
