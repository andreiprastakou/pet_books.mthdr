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
require 'rails_helper'

RSpec.describe WikiPageStat do
  subject(:stat) { build(:wiki_page_stat) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:entity_type) }
    it { is_expected.to validate_presence_of(:locale) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:views).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:views_last_month).is_greater_than_or_equal_to(0) }
  end
end
