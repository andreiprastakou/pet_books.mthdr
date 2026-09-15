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
    end
  end
end
