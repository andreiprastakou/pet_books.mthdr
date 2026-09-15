# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExternalLinkBuilders::LibraryThing do
  describe '.normalize_id' do
    {
      '33363109' => '33363109',
      '/work/33363109' => '33363109',
      'https://www.librarything.com/work/33363109' => '33363109'
    }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected.inspect}" do
        expect(described_class.normalize_id(input)).to eq(expected)
      end
    end

    it 'returns nil for blank values' do
      expect(described_class.normalize_id(nil)).to be_nil
      expect(described_class.normalize_id('')).to be_nil
    end
  end

  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      '33363109' => 'https://www.librarything.com/work/33363109',
      '/work/33363109' => 'https://www.librarything.com/work/33363109',
      'https://www.librarything.com/work/33363109' => 'https://www.librarything.com/work/33363109'
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
