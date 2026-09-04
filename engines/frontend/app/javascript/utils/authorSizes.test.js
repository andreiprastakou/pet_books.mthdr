import { describe, expect, it } from 'vitest'

import {
  AUTHOR_SIZES,
  DEFAULT_AUTHOR_SIZE,
  SMALLEST_AUTHOR_SIZE,
  authorSizeClass,
  authorSizeForWidth,
} from 'utils/authorSizes'

describe('authorSizes', () => {
  it('exposes size map and defaults', () => {
    expect(AUTHOR_SIZES).toEqual({
      sm: { thumb: 100 },
      lg: { thumb: 130 },
    })
    expect(DEFAULT_AUTHOR_SIZE).toBe('lg')
    expect(SMALLEST_AUTHOR_SIZE).toBe('sm')
  })

  it('builds a size class name', () => {
    expect(authorSizeClass('lg')).toBe('author-size-lg')
  })

  it('picks the widest size that fits available width', () => {
    expect(authorSizeForWidth(200)).toBe('lg')
    expect(authorSizeForWidth(130)).toBe('lg')
    expect(authorSizeForWidth(100)).toBe('sm')
    expect(authorSizeForWidth(50)).toBe('sm')
  })
})
