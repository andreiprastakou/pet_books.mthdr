import { describe, expect, it } from 'vitest'

import {
  collectionIdsByWorkId,
  compactStackFromUrl,
  displayedWorksCount,
  hiddenSelectionFor,
} from 'panels/booksStack/collectedWorksInList'

const booksIndex = {
  1: { id: 1, format: 'collection', collectedWorkIds: [2, 3] },
  4: { id: 4, format: 'collection', collectedWorkIds: [2] },
  2: { id: 2, format: 'small' },
  3: { id: 3, format: 'big' },
  5: { id: 5, format: 'normal' },
}

describe('collected works in the works list', () => {
  it('maps each nested book to the shown collections that include it', () => {
    const map = collectionIdsByWorkId([4, 1, 2, 5], booksIndex)

    expect(map.get(2)).toEqual([4, 1])
    expect(map.get(3)).toEqual([1])
    expect(map.has(5)).toBe(false)
  })

  it('ignores collections that are not in the list', () => {
    const map = collectionIdsByWorkId([2, 5], booksIndex)

    expect(map.size).toBe(0)
  })

  it('excludes collections from the displayed works total', () => {
    expect(displayedWorksCount([1, 2, 4, 5], 4, booksIndex)).toBe(2)
    expect(displayedWorksCount([2], 1, {})).toBe(1)
  })

  it('points a hidden book at the first shown collection', () => {
    const map = collectionIdsByWorkId([4, 1, 2], booksIndex)

    expect(hiddenSelectionFor(map, 2)).toEqual({ 'book_id': 4 })
    expect(hiddenSelectionFor(map, 4)).toBeNull()
  })

  it('reads compact stack from the url, closed unless set to 0', () => {
    const url = search => ({
      queryParameter: name => new URLSearchParams(search).get(name),
    })

    expect(compactStackFromUrl(url(''))).toBe(true)
    expect(compactStackFromUrl(url('?compact_stack=0'))).toBe(false)
    expect(compactStackFromUrl(url('?compact_stack=1'))).toBe(true)
  })
})