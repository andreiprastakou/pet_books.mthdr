import { describe, expect, it, vi } from 'vitest'

import reducer, { slice } from 'store/axis/slice'
import {
  selectCurrentAuthorId,
  selectCurrentBookId,
  selectCurrentTagId,
} from 'store/axis/selectors'

const {
  setCurrentAuthorId,
  setCurrentBookId,
  setCurrentTagId,
  setSeed,
} = slice.actions

describe('axis slice', () => {
  it('has a null initial navigational state', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      currentAuthorId: null,
      currentBookId: null,
      currentTagId: null,
      seed: null,
    })
  })

  it('sets current author, book, and tag ids', () => {
    let state = reducer(undefined, setCurrentAuthorId(11))
    state = reducer(state, setCurrentBookId(22))
    state = reducer(state, setCurrentTagId(33))

    expect(state.currentAuthorId).toBe(11)
    expect(state.currentBookId).toBe(22)
    expect(state.currentTagId).toBe(33)
  })

  it('sets seed to the current timestamp', () => {
    vi.spyOn(Date, 'now').mockReturnValue(1_700_000_000_000)
    const state = reducer(undefined, setSeed())
    expect(state.seed).toBe(1_700_000_000_000)
  })
})

describe('axis selectors', () => {
  const state = {
    axis: {
      currentAuthorId: 1,
      currentBookId: 2,
      currentTagId: 3,
      seed: 9,
    },
  }

  it('reads current ids from axis state', () => {
    expect(selectCurrentAuthorId()(state)).toBe(1)
    expect(selectCurrentBookId()(state)).toBe(2)
    expect(selectCurrentTagId()(state)).toBe(3)
  })
})
