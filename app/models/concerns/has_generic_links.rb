module HasGenericLinks
  extend ActiveSupport::Concern

  included do
    has_many :generic_links, as: :entity, class_name: 'GenericLink', dependent: :destroy, inverse_of: :entity

    accepts_nested_attributes_for :generic_links, allow_destroy: true
  end
end
