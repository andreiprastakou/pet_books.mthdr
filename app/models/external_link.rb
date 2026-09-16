# == Schema Information
#
# Table name: external_links
# Database name: primary
#
#  id                :integer          not null, primary key
#  external_resource :string           not null
#  locale            :string
#  owner_type        :string           not null
#  url               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  owner_id          :integer          not null
#
# Indexes
#
#  index_external_links_on_owner_type_and_owner_id  (owner_type,owner_id)
#
class ExternalLink < ApplicationRecord
  belongs_to :owner, polymorphic: true, optional: true, inverse_of: :external_links

  validates :owner_type, presence: true
  validates :external_resource, presence: true
  validates :url, presence: true

  scope :for_frontend, -> { where.not(external_resource: ExternalResources::INTERNAL) }

  def self.frontend_payload(links)
    links.reject { |link| ExternalResources::INTERNAL.include?(link.external_resource) }
         .map { |link| { external_resource: link.external_resource, url: link.url } }
  end
end
