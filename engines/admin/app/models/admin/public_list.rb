# frozen_string_literal: true

# == Schema Information
#
# Table name: public_lists
# Database name: primary
#
#  id                  :integer          not null, primary key
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  public_list_type_id :integer          not null
#
# Indexes
#
#  index_public_lists_on_public_list_type_id           (public_list_type_id)
#  index_public_lists_on_public_list_type_id_and_year  (public_list_type_id,year) UNIQUE
#
# Foreign Keys
#
#  public_list_type_id  (public_list_type_id => public_list_types.id)
#
module Admin
  class PublicList < ::PublicList
    include Admin::Castable
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities

    belongs_to :public_list_type, class_name: 'Admin::PublicListType', inverse_of: :public_lists
  end
end
