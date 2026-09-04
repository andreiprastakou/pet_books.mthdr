import { describe, expect, it } from 'vitest'

import { objectToParams } from 'utils/objectToParams'

describe('objectToParams', () => {
  it('returns empty string when object has no set values', () => {
    expect(objectToParams({})).toBe('')
    expect(objectToParams({ q: null, page: undefined, empty: '' })).toBe('')
  })

  it('builds a query string from scalar values', () => {
    expect(objectToParams({ q: 'tolstoy', page: 2 })).toBe('?q=tolstoy&page=2')
  })

  it('serializes arrays with bracket notation', () => {
    expect(objectToParams({ tag: ['fiction', 'classic'] })).toBe('?tag%5B%5D=fiction&tag%5B%5D=classic')
  })

  it('merges into and clears keys from initial params', () => {
    expect(objectToParams({ page: 2 }, 'q=tolstoy&page=1')).toBe('?q=tolstoy&page=2')
    expect(objectToParams({ page: null }, 'q=tolstoy&page=1')).toBe('?q=tolstoy')
  })
})
