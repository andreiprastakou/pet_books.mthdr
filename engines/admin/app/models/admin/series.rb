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
    include Admin::Castable
    include Admin::HasWikipedia
    include Admin::HasExternalIdentities
  end
end
