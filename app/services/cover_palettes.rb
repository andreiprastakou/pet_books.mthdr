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

  # Oxide pigments for small pamphlets. Lightness sits inside the novel band.
  SMALL_COVER_PALETTES = [
    { base: '#703329', mid: '#8a3a2e', shadow: '#47241f', edge: '#311a17' },
    { base: '#26375e', mid: '#2c4377', shadow: '#1a2337', edge: '#111622' },
    { base: '#465b33', mid: '#55723b', shadow: '#2d3824', edge: '#1e2419' },
    { base: '#5e3151', mid: '#763763', shadow: '#3a2233', edge: '#251821' },
    { base: '#6e462b', mid: '#885330', shadow: '#462f20', edge: '#302118' },
    { base: '#305551', mid: '#376c66', shadow: '#203230', edge: '#151e1d' },
    { base: '#6b592e', mid: '#846c33', shadow: '#443a22', edge: '#2e2819' },
    { base: '#5d323b', mid: '#743945', shadow: '#392327', edge: '#25181b' },
    { base: '#383c57', mid: '#40466d', shadow: '#272935', edge: '#1b1c22' },
    { base: '#53473c', mid: '#685645', shadow: '#322e29', edge: '#201e1d' }
  ].freeze

  # Near-white boards for collections — tinted, light enough for near-black type.
  COLLECTION_COVER_PALETTES = [
    { base: '#f6efea', mid: '#f9f4f1', shadow: '#e8dcd4', edge: '#dfd1c8' },
    { base: '#e7eef3', mid: '#edf3f7', shadow: '#d2dce5', edge: '#c7d2db' },
    { base: '#eaf1ed', mid: '#eff5f2', shadow: '#d7e0db', edge: '#cdd5d0' },
    { base: '#f0ecf4', mid: '#f5f2f8', shadow: '#ded8e4', edge: '#d4ceda' },
    { base: '#f3efe8', mid: '#f7f3ee', shadow: '#e3ddd3', edge: '#d9d3c9' },
    { base: '#e9f1f0', mid: '#eff6f5', shadow: '#d6e1df', edge: '#ccd7d5' },
    { base: '#f3f1e7', mid: '#f7f6ee', shadow: '#e4e2d3', edge: '#dad8c8' },
    { base: '#f4ebee', mid: '#f8f2f3', shadow: '#e4d7db', edge: '#dbcdd0' },
    { base: '#e9ebf1', mid: '#eff0f6', shadow: '#d6d8e1', edge: '#ccced7' },
    { base: '#eeeae7', mid: '#f3efed', shadow: '#dcd9d6', edge: '#d1cecc' }
  ].freeze

  module_function

  def for_id(id, small: false, collection: false)
    palettes = if collection
                 COLLECTION_COVER_PALETTES
               elsif small
                 SMALL_COVER_PALETTES
               else
                 COVER_PALETTES
               end
    palettes[id.to_i.abs % palettes.length]
  end

  def background_css(palette, flat: false)
    if flat
      "background: #{palette[:base]};"
    else
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
  end

  def background_css_for_id(id, small: false, collection: false)
    background_css(for_id(id, small:, collection:), flat: small)
  end
end
