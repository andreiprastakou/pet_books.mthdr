# frozen_string_literal: true

# == Schema Information
#
# Table name: genres
# Database name: primary
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cover_design_id :integer
#
# Indexes
#
#  index_genres_on_cover_design_id  (cover_design_id)
#  index_genres_on_name             (name) UNIQUE
#
# Foreign Keys
#
#  cover_design_id  (cover_design_id => cover_designs.id)
#
module Admin
  class Genre < ::Genre
    include HasExternalIdentities

    def readonly?
      false
    end

    def self.cast(genre)
      return genre if genre.is_a?(self)
      return new(genre.attributes) if genre.new_record?

      genre.becomes(self)
    end
  end
end
