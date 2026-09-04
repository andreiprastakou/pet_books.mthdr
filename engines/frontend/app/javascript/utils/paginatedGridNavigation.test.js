import { describe, expect, it } from 'vitest'

import {
  GRID_ROW_SIZE,
  isBlocked,
  keyType,
  pageSelection,
  targetSelection,
} from 'utils/paginatedGridNavigation'

describe('paginatedGridNavigation', () => {
  describe('keyType', () => {
    it('maps keyboard keys to navigation types', () => {
      expect(keyType('Enter')).toBe('enter')
      expect(keyType('ArrowLeft')).toBe('left')
      expect(keyType('Left')).toBe('left')
      expect(keyType('ArrowRight')).toBe('right')
      expect(keyType('Right')).toBe('right')
      expect(keyType('ArrowUp')).toBe('up')
      expect(keyType('Up')).toBe('up')
      expect(keyType('ArrowDown')).toBe('down')
      expect(keyType('Down')).toBe('down')
      expect(keyType('PageUp')).toBe('pageUp')
      expect(keyType('PageDown')).toBe('pageDown')
      expect(keyType('a')).toBeNull()
    })
  })

  describe('isBlocked', () => {
    const base = { index: 0, lastIndex: 7, page: 1, lastPage: 3, rowSize: GRID_ROW_SIZE }

    it('blocks left on the start of a row', () => {
      expect(isBlocked({ ...base, type: 'left', index: 0 })).toBe(true)
      expect(isBlocked({ ...base, type: 'left', index: 1 })).toBe(false)
    })

    it('blocks right at row end or last item', () => {
      expect(isBlocked({ ...base, type: 'right', index: 3 })).toBe(true)
      expect(isBlocked({ ...base, type: 'right', index: 7 })).toBe(true)
      expect(isBlocked({ ...base, type: 'right', index: 1 })).toBe(false)
    })

    it('blocks page navigation at bounds', () => {
      expect(isBlocked({ ...base, type: 'pageUp', page: 1 })).toBe(true)
      expect(isBlocked({ ...base, type: 'pageDown', page: 3 })).toBe(true)
      expect(isBlocked({ ...base, type: 'pageDown', page: 2 })).toBe(false)
    })
  })

  describe('targetSelection', () => {
    it('moves left and right within the page', () => {
      expect(targetSelection({ type: 'left', index: 2, page: 1, perPage: 16, totalCount: 40 }))
        .toEqual({ index: 1, page: 1 })
      expect(targetSelection({ type: 'right', index: 2, page: 1, perPage: 16, totalCount: 40 }))
        .toEqual({ index: 3, page: 1 })
    })

    it('moves up and down across pages with clamping', () => {
      expect(targetSelection({
        type: 'up', index: 1, page: 2, perPage: 16, totalCount: 40,
      })).toEqual({ index: 13, page: 1 })

      expect(targetSelection({
        type: 'down', index: 14, page: 2, perPage: 16, totalCount: 40,
      })).toEqual({ index: 2, page: 3 })

      expect(targetSelection({
        type: 'up', index: 0, page: 1, perPage: 16, totalCount: 40,
      })).toEqual({ index: 0, page: 1 })
    })
  })

  describe('pageSelection', () => {
    it('moves to the next or previous page and clamps index', () => {
      expect(pageSelection({
        type: 'pageDown', index: 10, page: 1, perPage: 16, totalCount: 20,
      })).toEqual({ index: 3, page: 2 })

      expect(pageSelection({
        type: 'pageUp', index: 2, page: 2, perPage: 16, totalCount: 40,
      })).toEqual({ index: 2, page: 1 })
    })
  })
})
