module HasWikiLinks
  extend ActiveSupport::Concern

  included do
    has_many :wiki_links, as: :entity, class_name: 'WikiLink', dependent: :destroy, inverse_of: :entity

    before_validation :refresh_wiki_links

    accepts_nested_attributes_for :wiki_links, allow_destroy: true

    validate :validate_wiki_url_format
  end

  def wiki_links_sum_views
    wiki_links.map(&:views).compact.sum
  end

  private

  def refresh_wiki_links
    return if wiki_url.blank?

    new_link = WikiLink.build_from_url(url: wiki_url) rescue nil
    return if new_link.nil?
    return if wiki_links.any? { |link| link.locale == new_link.locale && link.name == new_link.name }

    wiki_links.each(&:mark_for_destruction)
    wiki_links << new_link
  end

  def validate_wiki_url_format
    return if wiki_url.blank?

    name, locale = InfoFetchers::Wiki::UrlParser.extract_base_name_and_locale(wiki_url)
    errors.add(:wiki_url, 'is not a valid wikipedia url') if name.blank? || locale.blank?
  end
end
