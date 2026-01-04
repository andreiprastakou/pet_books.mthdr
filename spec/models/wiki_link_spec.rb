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
  subject(:link) { build(:wiki_link) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:entity_type) }
    it { is_expected.to validate_presence_of(:locale) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_numericality_of(:views).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:views_last_month).is_greater_than_or_equal_to(0) }

    it 'has a valid factory' do
      expect(build(:wiki_link, entity: build_stubbed(:book))).to be_valid
    end
  end

  describe '.build_from_url' do
    subject(:result) { described_class.build_from_url(url: url) }

    let(:url) { 'https://en.wikipedia.org/wiki/Test' }

    it 'builds a link from a URL' do
      expect(result.url).to eq(url)
      expect(result.locale).to eq('en')
      expect(result.name).to eq('Test')
    end
  end

  describe '.build_from_parts' do
    subject(:result) { described_class.build_from_parts(locale: locale, name: name) }

    let(:locale) { 'en' }
    let(:name) { 'Test' }

    it 'builds a link from parts' do
      expect(result.url).to eq('https://en.wikipedia.org/wiki/Test')
      expect(result.locale).to eq('en')
      expect(result.name).to eq('Test')
    end
  end

  describe '#same_link?' do
    subject(:result) { link.same_link?(other_link) }

    let(:link) { build_stubbed(:wiki_link, locale: 'en', name: 'TEST_A') }
    let(:other_link) { build_stubbed(:wiki_link, locale: 'en', name: 'TEST_A') }

    context 'when the links are the same' do
      it { is_expected.to be true }
    end

    context 'when locales are different' do
      before { other_link.locale = 'fr' }

      it { is_expected.to be false }
    end

    context 'when names are different' do
      before { other_link.name = 'TEST_C' }

      it { is_expected.to be false }
    end
  end
end
