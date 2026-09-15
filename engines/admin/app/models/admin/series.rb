# frozen_string_literal: true

# == Schema Information
#
# Table name: series
# Database name: primary
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_series_on_name  (name)
#
module Admin
  class Series < ::Series
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities

    def readonly?
      false
    end

    def self.cast(series)
      return series if series.is_a?(self)
      return new(series.attributes) if series.new_record?

      series.becomes(self)
    end
  end
end
