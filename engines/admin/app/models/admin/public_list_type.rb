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
    include Admin::Castable
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities

    has_many :public_lists, class_name: 'Admin::PublicList', dependent: :restrict_with_error,
                            inverse_of: :public_list_type
  end
end
