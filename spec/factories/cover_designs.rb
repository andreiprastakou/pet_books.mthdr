# == Schema Information
#
# Table name: cover_designs
# Database name: primary
#
#  id                :integer          not null, primary key
#  author_name_color :string           not null
#  author_name_font  :string           not null
#  cover_image       :string           not null
#  name              :string           not null
#  title_color       :string           not null
#  title_font        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :cover_design, class: 'CoverDesign' do
    sequence(:name) { |i| "DESIGN_#{i}" }
    title_color { CoverDesign::COLORS.sample }
    title_font { CoverDesign::FONTS.sample }
    author_name_color { CoverDesign::COLORS.sample }
    author_name_font { CoverDesign::FONTS.sample }
    cover_image { CoverDesign::COVER_IMAGES.sample }
  end
end
