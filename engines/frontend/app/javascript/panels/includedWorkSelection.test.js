import { describe, expect, it } from 'vitest'

import { includedWorkIdFromUrl } from 'panels/includedWorkSelection'

const urlFor = search => ({
  queryParameter: name => new URLSearchParams(search).get(name),
})

describe('includedWorkIdFromUrl', () => {
  it('reads a numeric included work id from the query', () => {
    expect(includedWorkIdFromUrl(urlFor(''))).toBeNull()
    expect(includedWorkIdFromUrl(urlFor('?book_id=5'))).toBeNull()
    expect(includedWorkIdFromUrl(urlFor('?included_work_id=abc'))).toBeNull()
    expect(includedWorkIdFromUrl(urlFor('?book_id=5&included_work_id=12'))).toBe(12)
  })
})
