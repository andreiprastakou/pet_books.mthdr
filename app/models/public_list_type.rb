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
class PublicListType < ApplicationRecord
  has_many :public_lists, class_name: 'PublicList', dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
