import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/booksYears/slice'
import { selectYears } from 'store/booksYears/selectors'

const { addYears, clearState } = slice.actions

describe('booksYears slice', () => {
  it('starts with no years', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({ years: [] })
  })

  it('merges, sorts, and uniques years', () => {
    const state = reducer(undefined, addYears([1990, 1980]))
    const next = reducer(state, addYears([1980, 2000]))

    expect(next.years).toEqual([1980, 1990, 2000])
  })

  it('clears years', () => {
    const previous = reducer(undefined, addYears([2001]))
    expect(reducer(previous, clearState()).years).toEqual([])
  })
})

describe('booksYears selectors', () => {
  it('returns a shallow copy of years', () => {
    const years = [1900, 2000]
    const state = { booksYears: { years } }
    const selected = selectYears()(state)

    expect(selected).toEqual(years)
    expect(selected).not.toBe(years)
  })
})
