# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExternalLinkBuilders::LibraryThing::Author do
  describe '.normalize_id' do
    {
      'koontzdean' => 'koontzdean',
      'jordanrobert-1' => 'jordanrobert-1',
      '/author/koontzdean' => 'koontzdean',
      'https://www.librarything.com/author/koontzdean' => 'koontzdean'
    }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected.inspect}" do
        expect(described_class.normalize_id(input)).to eq(expected)
      end
    end

    it 'returns nil for blank values and work paths' do
      expect(described_class.normalize_id(nil)).to be_nil
      expect(described_class.normalize_id('')).to be_nil
      expect(described_class.normalize_id('/work/33363109')).to be_nil
    end
  end

  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      'koontzdean' => 'https://www.librarything.com/author/koontzdean',
      '/author/koontzdean' => 'https://www.librarything.com/author/koontzdean',
      'https://www.librarything.com/author/koontzdean' => 'https://www.librarything.com/author/koontzdean'
    }.each do |input, expected|
      context "with #{input.inspect}" do
        let(:identificator) { input }

        it { is_expected.to eq(expected) }
      end
    end

    context 'with a blank identificator' do
      let(:identificator) { nil }

      it { is_expected.to be_nil }
    end
  end
end
