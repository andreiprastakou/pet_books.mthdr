# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExternalLinkBuilders::OpenLibrary::Author do
  describe '.normalize_id' do
    {
      '/authors/OL1394865A' => 'OL1394865A',
      'OL1394865A' => 'OL1394865A',
      'https://openlibrary.org/authors/OL1394865A' => 'OL1394865A',
      'https://openlibrary.org/authors/OL1394865A.json' => 'OL1394865A'
    }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected}" do
        expect(described_class.normalize_id(input)).to eq(expected)
      end
    end
  end

  describe '.call' do
    subject(:result) { described_class.call(identificator) }

    {
      '/authors/OL1394865A' => 'https://openlibrary.org/authors/OL1394865A',
      'OL1394865A' => 'https://openlibrary.org/authors/OL1394865A',
      'https://openlibrary.org/authors/OL1394865A' => 'https://openlibrary.org/authors/OL1394865A',
      'https://openlibrary.org/authors/OL1394865A.json' => 'https://openlibrary.org/authors/OL1394865A'
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
