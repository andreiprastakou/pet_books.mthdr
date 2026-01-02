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
class PublicListType < ApplicationRecord
  has_many :public_lists, class_name: 'PublicList', dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
