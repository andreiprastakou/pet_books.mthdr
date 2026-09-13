# == Schema Information
#
# Table name: external_links
# Database name: primary
#
#  id          :integer          not null, primary key
#  entity_type :string           not null
#  locale      :string
#  name        :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_id   :integer          not null
#
# Indexes
#
#  index_external_links_on_entity_type_and_entity_id  (entity_type,entity_id)
#
class ExternalLink < ApplicationRecord
  belongs_to :entity, polymorphic: true, optional: true, inverse_of: :external_links
  has_many :external_identities, dependent: :nullify, inverse_of: :external_link

  validates :entity_type, presence: true
  validates :name, presence: true
  validates :url, presence: true
end
