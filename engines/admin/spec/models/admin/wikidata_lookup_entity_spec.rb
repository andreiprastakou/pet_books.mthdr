# frozen_string_literal: true

require 'rails_helper'

# == Schema Information
#
# Table name: wikidata_lookup_entities
# Database name: primary
#
#  id          :integer          not null, primary key
#  description :string
#  fetched_at  :datetime
#  label       :string
#  qid         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_wikidata_lookup_entities_on_qid  (qid) UNIQUE
#
RSpec.describe Admin::WikidataLookupEntity do
  describe 'validation' do
    subject(:lookup_entity) { build(:wikidata_lookup_entity) }

    it 'has a valid factory' do
      expect(lookup_entity).to be_valid
    end

    it { is_expected.to validate_presence_of(:qid) }
    it { is_expected.to validate_uniqueness_of(:qid) }

    it 'requires a Q-ID format' do
      expect(build(:wikidata_lookup_entity, qid: 'not-a-qid')).not_to be_valid
    end
  end

  describe '.normalize_qid' do
    it 'delegates to the Wikidata API normalizer' do
      expect(described_class.normalize_qid('/wiki/Q42')).to eq('Q42')
    end
  end
end
