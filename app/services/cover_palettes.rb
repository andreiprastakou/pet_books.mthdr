# frozen_string_literal: true

# Cloth colours shared by every generated cover surface.
# Keep in sync with app/assets/javascripts/coverPalettes.js.
module CoverPalettes
  COVER_PALETTES = [
    { base: '#6b2222', mid: '#7a2a2a', shadow: '#4a1414', edge: '#3a1010' },
    { base: '#1f2f4f', mid: '#2a3d63', shadow: '#121f35', edge: '#0d1628' },
    { base: '#3a3a3a', mid: '#4a4a4a', shadow: '#252525', edge: '#1a1a1a' },
    { base: '#4a2030', mid: '#5a2840', shadow: '#301820', edge: '#241018' },
    { base: '#3d3428', mid: '#4d4335', shadow: '#2a231c', edge: '#1f1914' },
    { base: '#2a3a2a', mid: '#354835', shadow: '#1a241a', edge: '#121812' },
    { base: '#4a3a28', mid: '#5a4835', shadow: '#302518', edge: '#241c12' },
    { base: '#2a2838', mid: '#353345', shadow: '#181620', edge: '#121018' },
    { base: '#5a3020', mid: '#6a3a28', shadow: '#3a2015', edge: '#2a1810' },
    { base: '#283838', mid: '#334848', shadow: '#182020', edge: '#101818' }
  ].freeze

  # Pastel paper colours for small pamphlets — same shape, lighter palette.
  SMALL_COVER_PALETTES = [
    { base: '#e8c4c8', mid: '#f2d8dc', shadow: '#d4a8ae', edge: '#c4989e' },
    { base: '#b8cce0', mid: '#cce0f0', shadow: '#98b0c8', edge: '#88a0b8' },
    { base: '#c8d4c0', mid: '#dce8d4', shadow: '#a8bca0', edge: '#98ac90' },
    { base: '#d4c8e0', mid: '#e4daf0', shadow: '#b8a8c8', edge: '#a898b8' },
    { base: '#edd4c0', mid: '#f6e4d4', shadow: '#d8b8a0', edge: '#c8a890' },
    { base: '#c0dcd4', mid: '#d4ece4', shadow: '#a0c4b8', edge: '#90b4a8' },
    { base: '#ebe0c0', mid: '#f4ecd4', shadow: '#d4c8a0', edge: '#c4b890' },
    { base: '#e0c8d8', mid: '#eedae8', shadow: '#c8a8c0', edge: '#b898b0' },
    { base: '#c8c8e0', mid: '#dcdcf0', shadow: '#a8a8c8', edge: '#9898b8' },
    { base: '#d8d0c8', mid: '#e8e0d8', shadow: '#c0b8b0', edge: '#b0a8a0' }
  ].freeze

  module_function

  def for_id(id, small: false)
    palettes = small ? SMALL_COVER_PALETTES : COVER_PALETTES
    palettes[id.to_i.abs % palettes.length]
  end

  def background_css(palette)
    <<~CSS.squish
      background: linear-gradient(
        180deg,
        #{palette[:shadow]} 0%,
        #{palette[:base]} 18%,
        #{palette[:mid]} 50%,
        #{palette[:base]} 82%,
        #{palette[:shadow]} 100%
      );
    CSS
  end

  def background_css_for_id(id, small: false)
    background_css(for_id(id, small:))
  end
end
