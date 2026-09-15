# frozen_string_literal: true

# == Schema Information
#
# Table name: public_list_types
# Database name: primary
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_public_list_types_on_name  (name) UNIQUE
#
module Admin
  class PublicListType < ::PublicListType
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities

    has_many :public_lists, class_name: 'Admin::PublicList', dependent: :restrict_with_error,
                            inverse_of: :public_list_type

    def readonly?
      false
    end

    def self.cast(public_list_type)
      return public_list_type if public_list_type.is_a?(self)
      return new(public_list_type.attributes) if public_list_type.new_record?

      public_list_type.becomes(self)
    end
  end
end
