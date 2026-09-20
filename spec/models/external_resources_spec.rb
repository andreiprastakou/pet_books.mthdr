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

  describe 'LABELS' do
    it 'maps every known resource to a display label' do
      expect(described_class::LABELS.keys).to match_array(described_class::ALL)
      expect(described_class::LABELS).to include(
        described_class::OFFICIAL => 'Official',
        described_class::GOODREADS => 'Goodreads',
        described_class::LIBRARYTHING => 'LibraryThing',
        described_class::OPEN_LIBRARY => 'Open Library',
        described_class::WIKIPEDIA => 'Wikipedia'
      )
    end
  end

  describe '.label_for' do
    it 'returns the display label for a known resource' do
      expect(described_class.label_for(described_class::LIBRARYTHING)).to eq('LibraryThing')
    end

    it 'falls back to the raw slug for unknown resources' do
      expect(described_class.label_for('blog')).to eq('blog')
    end
  end
end
