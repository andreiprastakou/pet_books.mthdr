import { describe, expect, it } from 'vitest'

import { bookIdFromSearch } from 'utils/bookIdFromLocation'

describe('bookIdFromSearch', () => {
  it('returns null when book_id is missing or invalid', () => {
    expect(bookIdFromSearch('')).toBeNull()
    expect(bookIdFromSearch('?list_id=3')).toBeNull()
    expect(bookIdFromSearch('?book_id=abc')).toBeNull()
  })

  it('parses book_id from the query string', () => {
    expect(bookIdFromSearch('?book_id=227')).toBe(227)
    expect(bookIdFromSearch('?list_id=1&book_id=42')).toBe(42)
  })
})
