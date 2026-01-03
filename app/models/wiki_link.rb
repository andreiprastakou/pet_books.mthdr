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
class WikiLink < ApplicationRecord
  belongs_to :entity, polymorphic: true, optional: true, inverse_of: :wiki_links

  validates :entity_type, presence: true
  validates :locale, presence: true
  validates :name, presence: true
  validates :url, presence: true
  validates :views, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  validates :views_last_month, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }

  after_create :enqueue_sync

def self.build_from_parts(locale:, name:)
    new(locale: locale, name: name,
        url: "https://#{locale}.wikipedia.org/wiki/#{URI.encode_uri_component(name)}")
  end

  def self.build_from_url(url:)
    name, locale = InfoFetchers::Wiki::UrlParser.extract_base_name_and_locale(url)
    raise "Can't extract base name and locale from #{url}" if name.blank? || locale.blank?

    new(locale: locale, name: name, url: url)
  end

  private

  def enqueue_sync
    Admin::WikiLinkSyncJob.perform_later(id)
  end
end
