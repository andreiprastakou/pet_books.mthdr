import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/coverDesigns/slice'

const { assignCoverDesigns } = slice.actions

describe('coverDesigns slice', () => {
  it('has an empty unloaded initial state', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      coverDesigns: {},
      coverDesignsLoaded: false,
    })
  })

  it('indexes cover designs by id and marks them loaded', () => {
    const coverDesigns = [
      { id: 1, name: 'Classic' },
      { id: 2, name: 'Modern' },
    ]

    const state = reducer(undefined, assignCoverDesigns(coverDesigns))

    expect(state.coverDesignsLoaded).toBe(true)
    expect(state.coverDesigns).toEqual({
      1: coverDesigns[0],
      2: coverDesigns[1],
    })
  })

  it('replaces previously assigned cover designs', () => {
    const previous = reducer(undefined, assignCoverDesigns([{ id: 1, name: 'Old' }]))
    const next = reducer(previous, assignCoverDesigns([{ id: 3, name: 'New' }]))

    expect(next.coverDesigns).toEqual({ 3: { id: 3, name: 'New' } })
    expect(next.coverDesignsLoaded).toBe(true)
  })
})
