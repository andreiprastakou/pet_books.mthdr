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
  end
end
