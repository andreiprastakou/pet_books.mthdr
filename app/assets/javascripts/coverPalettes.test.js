import { describe, expect, it } from 'vitest'

import {
  FORMAT_COLLECTION,
  FORMAT_SMALL,
  coverBackgroundStyle,
  coverPaletteForId,
} from 'utils/coverPalettes'

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

  it('returns a stable oxide palette for small covers', () => {
    const palette = coverPaletteForId(0, FORMAT_SMALL)
    expect(palette).toEqual({
      base: '#703329',
      mid: '#8a3a2e',
      shadow: '#47241f',
      edge: '#311a17',
    })
    expect(coverPaletteForId(10, FORMAT_SMALL)).toEqual(palette)
    expect(coverPaletteForId(1, FORMAT_SMALL).base).toBe('#26375e')
  })

  it('returns a stable near-white palette for collections', () => {
    const palette = coverPaletteForId(0, FORMAT_COLLECTION)
    expect(palette).toEqual({
      base: '#f6efea',
      mid: '#f9f4f1',
      shadow: '#e8dcd4',
      edge: '#dfd1c8',
    })
    expect(coverPaletteForId(10, FORMAT_COLLECTION)).toEqual(palette)
    expect(coverPaletteForId(1, FORMAT_COLLECTION).base).toBe('#e7eef3')
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
    const palette = coverPaletteForId(0, FORMAT_SMALL)
    expect(coverBackgroundStyle(palette, { flat: true })).toEqual({
      background: palette.base,
    })
  })
})
