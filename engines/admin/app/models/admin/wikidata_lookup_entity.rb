# frozen_string_literal: true

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
module Admin
  class WikidataLookupEntity < ApplicationRecord
    self.table_name = 'wikidata_lookup_entities'

    QID_FORMAT = /\AQ\d+\z/

    validates :qid, presence: true, uniqueness: true, format: { with: QID_FORMAT }

    def self.normalize_qid(value)
      InfoFetchers::Wikidata::Api::BaseCaller.normalize_entity_id(value)
    end
  end
end
