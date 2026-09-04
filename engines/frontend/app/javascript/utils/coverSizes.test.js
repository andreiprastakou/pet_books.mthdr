import { describe, expect, it } from 'vitest'

import {
  COVER_SIZES,
  DEFAULT_COVER_SIZE,
  SMALLEST_COVER_SIZE,
  coverSizeClass,
  coverSizeForWidth,
} from 'utils/coverSizes'

describe('coverSizes', () => {
  it('exposes size map and defaults', () => {
    expect(COVER_SIZES).toEqual({
      xs: { height: 150, width: 100 },
      sm: { height: 180, width: 120 },
      md: { height: 210, width: 140 },
      lg: { height: 240, width: 160 },
    })
    expect(DEFAULT_COVER_SIZE).toBe('lg')
    expect(SMALLEST_COVER_SIZE).toBe('xs')
  })

  it('builds a size class name', () => {
    expect(coverSizeClass('md')).toBe('b-cover-size-md')
  })

  it('picks the widest size that fits available width', () => {
    expect(coverSizeForWidth(200)).toBe('lg')
    expect(coverSizeForWidth(160)).toBe('lg')
    expect(coverSizeForWidth(140)).toBe('md')
    expect(coverSizeForWidth(120)).toBe('sm')
    expect(coverSizeForWidth(100)).toBe('xs')
    expect(coverSizeForWidth(50)).toBe('xs')
  })
})
