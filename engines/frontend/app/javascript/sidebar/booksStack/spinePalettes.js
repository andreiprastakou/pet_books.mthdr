const SPINE_PALETTES = [
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

export const spinePaletteForId = id => SPINE_PALETTES[Math.abs(id) % SPINE_PALETTES.length]

export const spineBackgroundStyle = palette => ({
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
})
