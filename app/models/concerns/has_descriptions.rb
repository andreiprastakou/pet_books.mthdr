# frozen_string_literal: true

module HasDescriptions
  extend ActiveSupport::Concern

  included do
    has_many :descriptions, -> { order(:priority) }, as: :owner, class_name: 'Description', dependent: :destroy,
                                                     inverse_of: :owner

    accepts_nested_attributes_for :descriptions, allow_destroy: true
  end

  def description_for_source(source)
    source_type = source.is_a?(String) ? source : source.class.name
    descriptions.find_by(source_type: source_type)
  end

  def upsert_description_from_source!(source, text:, source_label: nil)
    description = descriptions.find_or_initialize_by(source_type: source.class.name)
    description.assign_attributes(
      text: text,
      source_label: source_label.presence,
      source_id: source.id
    )
    description.save!
    description
  end
end
