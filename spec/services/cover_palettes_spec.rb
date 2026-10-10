# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoverPalettes do
  describe '.for_id' do
    it 'returns a stable palette for a given id' do
      palette = described_class.for_id(0)
      expect(palette).to eq(
        base: '#6b2222',
        mid: '#7a2a2a',
        shadow: '#4a1414',
        edge: '#3a1010'
      )
      expect(described_class.for_id(10)).to eq(palette)
      expect(described_class.for_id(-10)).to eq(palette)
    end

    it 'cycles through the palette list' do
      expect(described_class.for_id(1)[:base]).to eq('#1f2f4f')
      expect(described_class.for_id(9)[:base]).to eq('#283838')
    end

    it 'returns a stable oxide palette for small covers' do
      palette = described_class.for_id(0, Book::FORMAT_SMALL)
      expect(palette).to eq(
        base: '#703329',
        mid: '#8a3a2e',
        shadow: '#47241f',
        edge: '#311a17'
      )
      expect(described_class.for_id(10, Book::FORMAT_SMALL)).to eq(palette)
      expect(described_class.for_id(1, Book::FORMAT_SMALL)[:base]).to eq('#26375e')
    end

    it 'returns a stable near-white palette for collections' do
      palette = described_class.for_id(0, Book::FORMAT_COLLECTION)
      expect(palette).to eq(
        base: '#f6efea',
        mid: '#f9f4f1',
        shadow: '#e8dcd4',
        edge: '#dfd1c8'
      )
      expect(described_class.for_id(10, Book::FORMAT_COLLECTION)).to eq(palette)
      expect(described_class.for_id(1, Book::FORMAT_COLLECTION)[:base]).to eq('#e7eef3')
    end

    it 'uses the novel palette for big covers' do
      expect(described_class.for_id(1, Book::FORMAT_BIG)).to eq(described_class.for_id(1, Book::FORMAT_NORMAL))
    end
  end

  describe '.background_css_for_id' do
    it 'builds a vertical cloth gradient from a palette' do
      palette = described_class.for_id(0)
      css = described_class.background_css_for_id(0)

      expect(css).to include(palette[:shadow])
      expect(css).to include(palette[:base])
      expect(css).to include(palette[:mid])
      expect(css).to include('linear-gradient')
    end

    it 'builds a flat fill from the small cover palette' do
      palette = described_class.for_id(0, Book::FORMAT_SMALL)
      css = described_class.background_css_for_id(0, Book::FORMAT_SMALL)

      expect(css).to eq("background: #{palette[:base]};")
    end

    it 'builds a cloth gradient from the collection palette' do
      palette = described_class.for_id(0, Book::FORMAT_COLLECTION)
      css = described_class.background_css_for_id(0, Book::FORMAT_COLLECTION)

      expect(css).to include(palette[:base])
      expect(css).to include('linear-gradient')
    end
  end
end
