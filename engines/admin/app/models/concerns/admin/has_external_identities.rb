# frozen_string_literal: true

module Admin
  module HasExternalIdentities
    extend ActiveSupport::Concern

    included do
      unless include?(HasExternalLinks)
        raise "#{name} must include HasExternalLinks before including Admin::HasExternalIdentities"
      end

      has_many :external_identities, class_name: 'Admin::ExternalIdentity', as: :owner, dependent: :destroy,
                                     inverse_of: :owner

      accepts_nested_attributes_for :external_identities, allow_destroy: true,
                                                          reject_if: lambda { |attrs|
                                                            blank = attrs['external_resource'].blank?
                                                            blank && attrs['external_id'].blank?
                                                          }

      after_save :introduce_changed_external_identities
    end

    private

    def introduce_changed_external_identities
      external_identities.each do |identity|
        next unless identity.saved_change_to_external_id?

        Admin::ExternalIdentityIntroductor.call(identity)
      end
    end
  end
end
