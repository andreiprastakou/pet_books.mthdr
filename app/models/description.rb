# frozen_string_literal: true

# == Schema Information
#
# Table name: descriptions
# Database name: primary
#
#  id           :integer          not null, primary key
#  owner_type   :string           not null
#  priority     :integer          default(0), not null
#  source_label :string
#  source_type  :string
#  text         :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :integer          not null
#  source_id    :integer
#
# Indexes
#
#  index_descriptions_on_owner_type_and_owner_id_and_priority  (owner_type,owner_id,priority)
#  index_descriptions_on_source_type_and_source_id             (source_type,source_id)
#
class Description < ApplicationRecord
  EXTERNAL_RESOURCE_BY_SOURCE_TYPE = {
    'Admin::Tasks::OpenLibraryAuthorFetch' => ExternalResources::OPEN_LIBRARY,
    'Admin::Tasks::OpenLibraryAuthorSearch' => ExternalResources::OPEN_LIBRARY,
    'Admin::Tasks::OpenLibraryBookFetch' => ExternalResources::OPEN_LIBRARY,
    'Admin::Tasks::OpenLibraryBookSearch' => ExternalResources::OPEN_LIBRARY,
    'Admin::Tasks::WikidataAuthorFetch' => ExternalResources::WIKIDATA,
    'Admin::Tasks::WikidataAuthorSearch' => ExternalResources::WIKIDATA,
    'Admin::Tasks::WikidataBookFetch' => ExternalResources::WIKIDATA,
    'Admin::Tasks::WikidataBookSearch' => ExternalResources::WIKIDATA,
    'Admin::Tasks::WikipediaAuthorFetch' => ExternalResources::WIKIPEDIA,
    'Admin::Tasks::WikipediaBookFetch' => ExternalResources::WIKIPEDIA
  }.freeze

  belongs_to :owner, polymorphic: true, inverse_of: :descriptions
  belongs_to :source, polymorphic: true, optional: true

  validates :text, presence: true
  validates :owner_type, presence: true
  validates :priority, presence: true, numericality: { only_integer: true }

  def summary_source
    source_label.presence || external_resource_for_source
  end

  def display_source_label
    source_label.presence || external_resource_for_source&.titleize
  end

  def external_resource_for_source
    EXTERNAL_RESOURCE_BY_SOURCE_TYPE[source_type]
  end
end
