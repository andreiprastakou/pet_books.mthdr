import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/metadata/slice'
import { selectPageIsLoading } from 'store/metadata/selectors'

const { setPageIsLoading } = slice.actions

describe('metadata slice', () => {
  it('starts with page not loading', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      pageIsLoading: false,
    })
  })

  it('coerces payload to a boolean loading flag', () => {
    expect(reducer(undefined, setPageIsLoading(true)).pageIsLoading).toBe(true)
    expect(reducer(undefined, setPageIsLoading(1)).pageIsLoading).toBe(true)
    expect(reducer(undefined, setPageIsLoading(0)).pageIsLoading).toBe(false)
    expect(reducer(undefined, setPageIsLoading(null)).pageIsLoading).toBe(false)
  })
})

describe('metadata selectors', () => {
  it('selects page loading state', () => {
    expect(selectPageIsLoading()({ metadata: { pageIsLoading: true } })).toBe(true)
  })
})
