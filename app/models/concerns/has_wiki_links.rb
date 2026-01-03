module HasWikiLinks
  extend ActiveSupport::Concern

  included do
    has_many :wiki_links, as: :entity, class_name: 'WikiLink', dependent: :destroy

    before_validation :refresh_wiki_links

    accepts_nested_attributes_for :wiki_links, allow_destroy: true
  end

  private

  def refresh_wiki_links
    return if wiki_url.blank?

    new_link = WikiLink.build_from_url(entity: self, url: wiki_url)
    return if wiki_links.any? { |link| link.locale == new_link.locale && link.name == new_link.name }

    wiki_links.each(&:mark_for_destruction)
    wiki_links << new_link
  end
end
