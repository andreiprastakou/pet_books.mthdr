# == Schema Information
#
# Table name: wiki_page_stats
# Database name: primary
#
#  id               :integer          not null, primary key
#  entity_type      :string           not null
#  locale           :string           not null
#  name             :string           not null
#  views            :integer
#  views_last_month :integer
#  views_synced_at  :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  entity_id        :integer          not null
#
# Indexes
#
#  index_wiki_page_stats_on_entity  (entity_type,entity_id)
#
class WikiPageStat < ApplicationRecord
  belongs_to :entity, polymorphic: true, optional: true

  validates :entity_id, presence: true
  validates :entity_type, presence: true
  validates :locale, presence: true
  validates :name, presence: true
  validates :views, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :views_last_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
