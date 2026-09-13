module HasExternalLinks
  extend ActiveSupport::Concern

  included do
    has_many :external_links, as: :entity, class_name: 'ExternalLink', dependent: :destroy, inverse_of: :entity

    accepts_nested_attributes_for :external_links, allow_destroy: true
  end
end
