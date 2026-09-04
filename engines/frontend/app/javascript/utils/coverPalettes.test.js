import { describe, expect, it } from 'vitest'

import { coverBackgroundStyle, coverPaletteForId } from 'utils/coverPalettes'

describe('coverPalettes', () => {
  it('returns a stable palette for a given id', () => {
    const palette = coverPaletteForId(0)
    expect(palette).toEqual({
      base: '#6b2222',
      mid: '#7a2a2a',
      shadow: '#4a1414',
      edge: '#3a1010',
    })
    expect(coverPaletteForId(10)).toEqual(palette)
    expect(coverPaletteForId(-10)).toEqual(palette)
  })

  it('cycles through the palette list', () => {
    expect(coverPaletteForId(1).base).toBe('#1f2f4f')
    expect(coverPaletteForId(9).base).toBe('#283838')
  })

  it('builds a vertical cloth gradient from a palette', () => {
    const palette = coverPaletteForId(0)
    const style = coverBackgroundStyle(palette)

    expect(style.background).toContain(palette.shadow)
    expect(style.background).toContain(palette.base)
    expect(style.background).toContain(palette.mid)
    expect(style.background).toContain('linear-gradient')
  })
})
