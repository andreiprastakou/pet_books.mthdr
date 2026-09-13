module HasExternalLinks
  extend ActiveSupport::Concern

  included do
    has_many :external_links, as: :owner, class_name: 'ExternalLink', dependent: :destroy, inverse_of: :owner

    accepts_nested_attributes_for :external_links, allow_destroy: true
  end
end
