// Cloth colours shared by every generated cover surface: stack spines, default
// front covers and the back board behind them.
// Keep in sync with CoverPalettes (app/services/cover_palettes.rb).
const COVER_PALETTES = [
  { base: '#6b2222', mid: '#7a2a2a', shadow: '#4a1414', edge: '#3a1010' },
  { base: '#1f2f4f', mid: '#2a3d63', shadow: '#121f35', edge: '#0d1628' },
  { base: '#3a3a3a', mid: '#4a4a4a', shadow: '#252525', edge: '#1a1a1a' },
  { base: '#4a2030', mid: '#5a2840', shadow: '#301820', edge: '#241018' },
  { base: '#3d3428', mid: '#4d4335', shadow: '#2a231c', edge: '#1f1914' },
  { base: '#2a3a2a', mid: '#354835', shadow: '#1a241a', edge: '#121812' },
  { base: '#4a3a28', mid: '#5a4835', shadow: '#302518', edge: '#241c12' },
  { base: '#2a2838', mid: '#353345', shadow: '#181620', edge: '#121018' },
  { base: '#5a3020', mid: '#6a3a28', shadow: '#3a2015', edge: '#2a1810' },
  { base: '#283838', mid: '#334848', shadow: '#182020', edge: '#101818' },
]

// Pastel paper colours for small pamphlets — same shape, lighter palette.
const SMALL_COVER_PALETTES_PASTEL = [
  { base: '#e8c4c8', mid: '#f2d8dc', shadow: '#d4a8ae', edge: '#c4989e' },
  { base: '#b8cce0', mid: '#cce0f0', shadow: '#98b0c8', edge: '#88a0b8' },
  { base: '#c8d4c0', mid: '#dce8d4', shadow: '#a8bca0', edge: '#98ac90' },
  { base: '#d4c8e0', mid: '#e4daf0', shadow: '#b8a8c8', edge: '#a898b8' },
  { base: '#edd4c0', mid: '#f6e4d4', shadow: '#d8b8a0', edge: '#c8a890' },
  { base: '#c0dcd4', mid: '#d4ece4', shadow: '#a0c4b8', edge: '#90b4a8' },
  { base: '#ebe0c0', mid: '#f4ecd4', shadow: '#d4c8a0', edge: '#c4b890' },
  { base: '#e0c8d8', mid: '#eedae8', shadow: '#c8a8c0', edge: '#b898b0' },
  { base: '#c8c8e0', mid: '#dcdcf0', shadow: '#a8a8c8', edge: '#9898b8' },
  { base: '#d8d0c8', mid: '#e8e0d8', shadow: '#c0b8b0', edge: '#b0a8a0' },
]

// --- Experimental small-cover palettes (swap into SMALL_COVER_PALETTES to try) ---

// Bright hues pulled toward grey — less candy, still readable as colour.
const SMALL_COVER_PALETTES_GREYISH = [
  { base: '#c9b8ba', mid: '#d6c8ca', shadow: '#b0a0a2', edge: '#a09092' },
  { base: '#aebac6', mid: '#bec8d2', shadow: '#96a2ae', edge: '#86929e' },
  { base: '#b6beb4', mid: '#c6ccc4', shadow: '#9ea69c', edge: '#8e968c' },
  { base: '#bab4c2', mid: '#cac4d0', shadow: '#a29caa', edge: '#928c9a' },
  { base: '#c6b8ac', mid: '#d4c8bc', shadow: '#b0a298', edge: '#a09288' },
  { base: '#b0beb8', mid: '#c0ccc6', shadow: '#98a6a0', edge: '#889690' },
  { base: '#c4beae', mid: '#d2ccbe', shadow: '#aea898', edge: '#9e9888' },
  { base: '#c2b4bc', mid: '#d0c4cc', shadow: '#aa9ca4', edge: '#9a8c94' },
  { base: '#b4b4c2', mid: '#c4c4d0', shadow: '#9c9caa', edge: '#8c8c9a' },
  { base: '#bcb8b2', mid: '#cac6c0', shadow: '#a6a29c', edge: '#96928c' },
]

// Same pastel family, stepped down in value — closer to cloth books.
const SMALL_COVER_PALETTES_DARK_PASTEL = [
  { base: '#b88890', mid: '#c898a0', shadow: '#986870', edge: '#885860' },
  { base: '#7898b0', mid: '#88a8c0', shadow: '#587890', edge: '#486880' },
  { base: '#889880', mid: '#98a890', shadow: '#687860', edge: '#586850' },
  { base: '#9888a8', mid: '#a898b8', shadow: '#786888', edge: '#685878' },
  { base: '#b89878', mid: '#c8a888', shadow: '#987858', edge: '#886848' },
  { base: '#789890', mid: '#88a8a0', shadow: '#587870', edge: '#486860' },
  { base: '#b0a878', mid: '#c0b888', shadow: '#908858', edge: '#807848' },
  { base: '#a88898', mid: '#b898a8', shadow: '#886878', edge: '#785868' },
  { base: '#8888a8', mid: '#9898b8', shadow: '#686888', edge: '#585878' },
  { base: '#a09888', mid: '#b0a898', shadow: '#807868', edge: '#706858' },
]

// Dusty earth / library card — quiet, paper-adjacent, sits next to dark cloth.
const SMALL_COVER_PALETTES_EARTH = [
  { base: '#c4b09a', mid: '#d2c0ac', shadow: '#aa967e', edge: '#9a8670' },
  { base: '#a8a090', mid: '#b8b0a0', shadow: '#8e8678', edge: '#7e7668' },
  { base: '#b09a8c', mid: '#c0aa9c', shadow: '#948074', edge: '#847064' },
  { base: '#9a9488', mid: '#aaa498', shadow: '#807a70', edge: '#706a60' },
  { base: '#b8a888', mid: '#c8b898', shadow: '#9e8e70', edge: '#8e7e60' },
  { base: '#a89880', mid: '#b8a890', shadow: '#8e7e68', edge: '#7e6e58' },
  { base: '#c0b4a0', mid: '#d0c4b0', shadow: '#a69886', edge: '#968876' },
  { base: '#968c7c', mid: '#a69c8c', shadow: '#7c7264', edge: '#6c6254' },
  { base: '#ac9c8c', mid: '#bcac9c', shadow: '#908074', edge: '#807064' },
  { base: '#b4a894', mid: '#c4b8a4', shadow: '#988c7a', edge: '#887c6a' },
]

// Fog / mist — nearly neutral with a whisper of hue; least contrasty option.
const SMALL_COVER_PALETTES_MIST = [
  { base: '#c8c2c4', mid: '#d4d0d2', shadow: '#b0aaac', edge: '#a09a9c' },
  { base: '#c0c4c8', mid: '#ccd0d4', shadow: '#a8acb0', edge: '#989ca0' },
  { base: '#c4c6c2', mid: '#d0d2ce', shadow: '#aaaca8', edge: '#9a9c98' },
  { base: '#c4c2c8', mid: '#d0ced4', shadow: '#aaa8ae', edge: '#9a989e' },
  { base: '#cac6c0', mid: '#d6d2cc', shadow: '#b2aea8', edge: '#a29e98' },
  { base: '#c2c6c4', mid: '#ced2d0', shadow: '#a8acaa', edge: '#989c9a' },
  { base: '#c8c6c0', mid: '#d4d2cc', shadow: '#b0aea8', edge: '#a09e98' },
  { base: '#c6c2c6', mid: '#d2ced2', shadow: '#aca8ac', edge: '#9c989c' },
  { base: '#c2c2c6', mid: '#ceced2', shadow: '#a8a8ac', edge: '#98989c' },
  { base: '#c6c4c2', mid: '#d2d0ce', shadow: '#acaaa8', edge: '#9c9a98' },
]

// Soft slate / ink wash — mid-grey pastels that echo the dark cloth stack.
const SMALL_COVER_PALETTES_SLATE = [
  { base: '#8a7e82', mid: '#9a8e92', shadow: '#6e6468', edge: '#5e5458' },
  { base: '#7a848e', mid: '#8a949e', shadow: '#5e6872', edge: '#4e5862' },
  { base: '#7e8680', mid: '#8e968e', shadow: '#626a64', edge: '#525a54' },
  { base: '#84808c', mid: '#94909c', shadow: '#686470', edge: '#585460' },
  { base: '#8e8478', mid: '#9e9488', shadow: '#72685e', edge: '#62584e' },
  { base: '#788882', mid: '#889892', shadow: '#5c6c66', edge: '#4c5c56' },
  { base: '#8a8678', mid: '#9a9688', shadow: '#6e6a5e', edge: '#5e5a4e' },
  { base: '#867e86', mid: '#968e96', shadow: '#6a626a', edge: '#5a525a' },
  { base: '#7e7e8a', mid: '#8e8e9a', shadow: '#62626e', edge: '#52525e' },
  { base: '#86827c', mid: '#96928c', shadow: '#6a6660', edge: '#5a5650' },
]

const paletteList = small => (small ? SMALL_COVER_PALETTES_DARK_PASTEL : COVER_PALETTES)

export const coverPaletteForId = (id, { small = false } = {}) => {
  const palettes = paletteList(small)
  return palettes[Math.abs(id) % palettes.length]
}

export const coverBackgroundStyle = (palette, { flat = false } = {}) => (
  flat
    ? { background: palette.base }
    : {
      background: `
        linear-gradient(
          180deg,
          ${palette.shadow} 0%,
          ${palette.base} 18%,
          ${palette.mid} 50%,
          ${palette.base} 82%,
          ${palette.shadow} 100%
        )
      `,
    }
)
