# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExternalLinkBuilders::Goodreads::Author do
  describe '.normalize_id' do
    {
      '9355' => '9355',
      '/author/show/9355' => '9355',
      'https://www.goodreads.com/author/show/9355' => '9355',
      'https://www.goodreads.com/author/show/9355.Dean_Koontz' => '9355'
    }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected.inspect}" do
        expect(described_class.normalize_id(input)).to eq(expected)
      end
    end

    it 'returns nil for blank values and work paths' do
      expect(described_class.normalize_id(nil)).to be_nil
      expect(described_class.normalize_id('')).to be_nil
      expect(described_class.normalize_id('/work/editions/87596585')).to be_nil
    end
  end

  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      '9355' => 'https://www.goodreads.com/author/show/9355',
      '/author/show/9355' => 'https://www.goodreads.com/author/show/9355',
      'https://www.goodreads.com/author/show/9355.Dean_Koontz' => 'https://www.goodreads.com/author/show/9355'
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
