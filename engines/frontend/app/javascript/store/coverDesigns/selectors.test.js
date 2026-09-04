import { describe, expect, it } from 'vitest'

import {
  selectCoverDesign,
  selectCoverDesignsLoaded,
} from 'store/coverDesigns/selectors'

describe('coverDesigns selectors', () => {
  const state = {
    storeCoverDesigns: {
      coverDesigns: {
        1: { id: 1, name: 'Classic' },
      },
      coverDesignsLoaded: true,
    },
  }

  it('selects a cover design by id and loaded flag', () => {
    expect(selectCoverDesign(1)(state)).toEqual({ id: 1, name: 'Classic' })
    expect(selectCoverDesign(2)(state)).toBeUndefined()
    expect(selectCoverDesignsLoaded()(state)).toBe(true)
  })
})
