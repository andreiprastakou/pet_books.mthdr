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
class CoverDesign < ApplicationRecord
  include HasCodifiedName

  FONTS = %w[
    montserrat
    bebas_neue
    playfair_display
    libre_baskerville
    amarante
    cinzel
    iceberg
    special_elite
  ].freeze

  COLORS = %w[
    antiquewhite
    black
    gold
    white
  ].freeze

  COVER_IMAGES = %w[
    default
    blue_red_marks
    blue_smoke
    blurry_glass
    brown_skin
    brown_wave
    chalk_board
    dark_red
    dark_room
    fire
    gray_marks
    hard_blue_texture
    light_beam
    modern
    paper_pieces
    parchment
    red_scratches
    steps
    trees_stars
    wall_windows
    water_rocks
    wood_plank
    yellow_vector
  ].freeze

  DEFAULT_NAME = 'default'.freeze

  validates :name, presence: true
  validates :title_color, presence: true
  validates :title_font, presence: true
  validates :author_name_color, presence: true
  validates :author_name_font, presence: true
  validates :cover_image, presence: true

  define_codified_attribute :name
  define_codified_attribute :title_font
  define_codified_attribute :author_name_font

  def self.default
    find_by(name: DEFAULT_NAME)
  end
end
