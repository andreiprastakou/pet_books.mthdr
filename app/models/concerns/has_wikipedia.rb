# frozen_string_literal: true

# Wikipedia URL stored as an ExternalLink, plus derived WikiLink rows for stats.
module HasWikipedia
  extend ActiveSupport::Concern

  included do
    has_many :wiki_links, as: :entity, class_name: 'WikiLink', dependent: :destroy, inverse_of: :entity

    before_validation :refresh_wiki_links

    accepts_nested_attributes_for :wiki_links, allow_destroy: true

    validate :validate_wiki_url_format
  end

  def wikipedia_external_link
    external_links.find do |link|
      !link.marked_for_destruction? && link.external_resource == ExternalResources::WIKIPEDIA
    end
  end

  def wiki_url
    wikipedia_external_link&.url
  end

  def wiki_url=(value)
    normalized = value.to_s.strip.presence
    link = wikipedia_external_link

    if normalized.blank?
      link&.mark_for_destruction
      return
    end

    if link
      link.url = normalized
    else
      external_links.build(external_resource: ExternalResources::WIKIPEDIA, url: normalized)
    end
  end

  def wiki_links_sum_views
    wiki_links.map(&:views).compact.sum
  end

  private

  # rubocop:disable Style/RescueModifier
  def refresh_wiki_links
    return if wiki_url.blank?

    new_link = WikiLink.build_from_url(url: wiki_url) rescue nil
    return if new_link.nil?
    return if wiki_links.any? { |link| link.same_link?(new_link) }

    wiki_links.each(&:mark_for_destruction)
    wiki_links << new_link
  end
  # rubocop:enable Style/RescueModifier

  def validate_wiki_url_format
    return if wiki_url.blank?

    name, locale = Admin::InfoFetchers::Wiki::UrlParser.extract_base_name_and_locale(wiki_url)
    errors.add(:wiki_url, 'is not a valid wikipedia url') if name.blank? || locale.blank?
  end
end
