import { describe, expect, it } from 'vitest'

import {
  includedWorkIdsFor,
  includedWorksAuthorPlacement,
} from 'panels/bookDetails/includedWorksAuthorPlacement'

describe('includedWorkIdsFor', () => {
  it('returns collected work ids only for collections that have them', () => {
    expect(includedWorkIdsFor({ format: 'big', collectedWorkIds: [1] })).toBeNull()
    expect(includedWorkIdsFor({ format: 'collection', collectedWorkIds: [] })).toBeNull()
    expect(includedWorkIdsFor({ format: 'collection', collectedWorkIds: [1, 2] })).toEqual([1, 2])
  })
})

describe('includedWorksAuthorPlacement', () => {
  it('waits until every included work is loaded', () => {
    expect(includedWorksAuthorPlacement([1, 2], { 1: { authorIds: [9] } })).toBeNull()
  })

  it('puts shared author sets on the heading', () => {
    expect(includedWorksAuthorPlacement([1, 2], {
      1: { authorIds: [9, 3] },
      2: { authorIds: [3, 9] },
    })).toBe('heading')
  })

  it('puts mixed author sets on the entries', () => {
    expect(includedWorksAuthorPlacement([1, 2], {
      1: { authorIds: [9] },
      2: { authorIds: [3] },
    })).toBe('entries')
  })
})
