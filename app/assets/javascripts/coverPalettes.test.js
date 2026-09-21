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

  it('returns a stable pastel palette for small covers', () => {
    const palette = coverPaletteForId(0, { small: true })
    expect(palette).toEqual({
      base: '#e8c4c8',
      mid: '#f2d8dc',
      shadow: '#d4a8ae',
      edge: '#c4989e',
    })
    expect(coverPaletteForId(10, { small: true })).toEqual(palette)
    expect(coverPaletteForId(1, { small: true }).base).toBe('#b8cce0')
  })

  it('builds a vertical cloth gradient from a palette', () => {
    const palette = coverPaletteForId(0)
    const style = coverBackgroundStyle(palette)

    expect(style.background).toContain(palette.shadow)
    expect(style.background).toContain(palette.base)
    expect(style.background).toContain(palette.mid)
    expect(style.background).toContain('linear-gradient')
  })

  it('builds a flat matte fill when requested', () => {
    const palette = coverPaletteForId(0, { small: true })
    expect(coverBackgroundStyle(palette, { flat: true })).toEqual({
      background: palette.base,
    })
  })
})
