import { describe, expect, it } from 'vitest'

import store from 'store/store'

describe('root store', () => {
  it('wires the expected reducer keys', () => {
    const state = store.getState()
    expect(Object.keys(state).sort()).toEqual([
      'authorsPage',
      'axis',
      'booksList',
      'booksYears',
      'imageModal',
      'metadata',
      'notifications',
      'storeAuthors',
      'storeBooks',
      'storeCoverDesigns',
      'storeTags',
    ].sort())
  })
})
