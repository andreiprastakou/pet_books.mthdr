import { describe, expect, it } from 'vitest'

import UrlStoreContext from 'store/urlStore/Context'

describe('urlStore Context', () => {
  it('exports a React context', () => {
    expect(UrlStoreContext).toBeDefined()
    expect(UrlStoreContext.Provider).toBeDefined()
  })
})
