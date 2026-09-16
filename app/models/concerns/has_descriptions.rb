# frozen_string_literal: true

module HasDescriptions
  extend ActiveSupport::Concern

  included do
    has_many :descriptions, -> { order(:priority) }, as: :owner, class_name: 'Description', dependent: :destroy,
                                                     inverse_of: :owner

    accepts_nested_attributes_for :descriptions, allow_destroy: true
  end
end
