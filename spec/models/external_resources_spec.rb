# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalResources do
  describe 'constants' do
    it 'defines a slug for each known resource' do
      expect(described_class::OFFICIAL).to eq('official')
      expect(described_class::FAN).to eq('fan')
      expect(described_class::GOODREADS).to eq('goodreads')
      expect(described_class::LIBRARYTHING).to eq('librarything')
      expect(described_class::OPEN_LIBRARY).to eq('open_library')
      expect(described_class::WIKIDATA).to eq('wikidata')
      expect(described_class::WIKIPEDIA).to eq('wikipedia')
    end
  end

  describe 'ALL' do
    it 'lists every resource slug' do
      expect(described_class::ALL).to contain_exactly(
        described_class::OFFICIAL,
        described_class::FAN,
        described_class::GOODREADS,
        described_class::LIBRARYTHING,
        described_class::OPEN_LIBRARY,
        described_class::WIKIDATA,
        described_class::WIKIPEDIA
      )
    end
  end

  describe 'INTERNAL' do
    it 'lists resources reserved for admin use' do
      expect(described_class::INTERNAL).to contain_exactly(described_class::WIKIDATA)
      expect(described_class::INTERNAL - described_class::ALL).to be_empty
    end
  end
end
