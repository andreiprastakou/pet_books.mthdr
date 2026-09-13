# frozen_string_literal: true

# == Schema Information
#
# Table name: external_identities
# Database name: primary
#
#  id                :integer          not null, primary key
#  external_resource :integer          not null
#  identificator     :string
#  owner_type        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  external_link_id  :integer
#  owner_id          :integer          not null
#
# Indexes
#
#  idx_on_external_resource_identificator_ab3aeda95b     (external_resource,identificator) UNIQUE
#  index_external_identities_on_external_link_id         (external_link_id)
#  index_external_identities_on_owner_type_and_owner_id  (owner_type,owner_id)
#
# Foreign Keys
#
#  external_link_id  (external_link_id => external_links.id) ON DELETE => nullify
#
class ExternalIdentity < ApplicationRecord
  belongs_to :owner, polymorphic: true, inverse_of: :external_identities
  belongs_to :external_link, optional: true
  has_many :open_library_fetch_tasks, class_name: 'Admin::OpenLibraryFetchTask', as: :target, dependent: :destroy
  has_many :open_library_author_fetch_tasks, class_name: 'Admin::OpenLibraryAuthorFetchTask', as: :target,
                                             dependent: :destroy
  has_many :wikidata_fetch_tasks, class_name: 'Admin::WikidataFetchTask', as: :target, dependent: :destroy

  enum :external_resource, {
    ExternalResources::OPEN_LIBRARY => 1,
    ExternalResources::WIKIDATA => 2,
    ExternalResources::LIBRARYTHING => 3,
    ExternalResources::GOODREADS => 4
  }

  validates :owner_type, presence: true
  validates :external_resource, presence: true
  validates :identificator, uniqueness: { scope: :external_resource }, allow_nil: true

  after_commit :enqueue_open_library_fetch_task, on: :create

  private

  def enqueue_open_library_fetch_task
    return unless open_library?

    case owner
    when Book
      Admin::OpenLibraryFetchTask.setup(self).enqueue_for_processing!
    when Author
      Admin::OpenLibraryAuthorFetchTask.setup(self).enqueue_for_processing!
    end
  end
end

