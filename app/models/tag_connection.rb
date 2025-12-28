# frozen_string_literal: true

# == Schema Information
#
# Table name: tag_connections
# Database name: primary
#
#  id          :integer          not null, primary key
#  entity_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_id   :integer          not null
#  tag_id      :integer          not null
#
# Indexes
#
#  index_tag_connections_on_entity_type_and_entity_id_and_tag_id  (entity_type,entity_id,tag_id) UNIQUE
#  index_tag_connections_on_tag_id                                (tag_id)
#
class TagConnection < ApplicationRecord
  belongs_to :tag, class_name: 'Tag', inverse_of: :tag_connections
  belongs_to :entity, polymorphic: true
end
