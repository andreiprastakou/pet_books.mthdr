# == Schema Information
#
# Table name: wiki_links
# Database name: primary
#
#  id               :integer          not null, primary key
#  entity_type      :string           not null
#  locale           :string           not null
#  name             :string           not null
#  url              :string           not null
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

RSpec.describe WikiLink do
  subject(:stat) { build(:wiki_link) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:entity_type) }
    it { is_expected.to validate_presence_of(:locale) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_numericality_of(:views).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:views_last_month).is_greater_than_or_equal_to(0) }
  end

  describe '.build_from_url' do
    subject(:result) { described_class.build_from_url(entity: entity, url: url) }

    let(:url) { 'https://en.wikipedia.org/wiki/Test' }
    let(:entity) { build_stubbed(:book) }

    it 'builds a link from a URL' do
      expect(result.url).to eq(url)
      expect(result.locale).to eq('en')
      expect(result.name).to eq('Test')
      expect(result.entity).to eq(entity)
    end
  end

  describe '.build_from_parts' do
    subject(:result) { described_class.build_from_parts(entity: entity, locale: locale, name: name) }

    let(:entity) { build_stubbed(:book) }
    let(:locale) { 'en' }
    let(:name) { 'Test' }

    it 'builds a link from parts' do
      expect(result.url).to eq("https://en.wikipedia.org/wiki/Test")
      expect(result.locale).to eq('en')
      expect(result.name).to eq('Test')
      expect(result.entity).to eq(entity)
    end
  end
end
