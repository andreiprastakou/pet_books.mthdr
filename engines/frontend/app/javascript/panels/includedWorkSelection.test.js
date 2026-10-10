import { describe, expect, it } from 'vitest'

import { includedWorkIdFromUrl, shouldClearIncludedWork } from 'panels/includedWorkSelection'

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

describe('shouldClearIncludedWork', () => {
  const collection = { format: 'collection', collectedWorkIds: [8] }

  it('keeps a work chosen together with its collection', () => {
    expect(shouldClearIncludedWork({
      book: null,
      bookChanged: true,
      includedWorkChanged: true,
      includedWorkId: 8,
    })).toBe(false)
    expect(shouldClearIncludedWork({
      book: collection,
      bookChanged: true,
      includedWorkChanged: true,
      includedWorkId: 8,
    })).toBe(false)
  })

  it('clears a leftover work when the selected book changes', () => {
    expect(shouldClearIncludedWork({
      book: collection,
      bookChanged: true,
      includedWorkChanged: false,
      includedWorkId: 8,
    })).toBe(true)
  })

  it('clears a work the loaded book does not contain', () => {
    expect(shouldClearIncludedWork({
      book: collection,
      bookChanged: false,
      includedWorkChanged: false,
      includedWorkId: 9,
    })).toBe(true)
    expect(shouldClearIncludedWork({
      book: null,
      bookChanged: false,
      includedWorkChanged: false,
      includedWorkId: null,
    })).toBe(false)
  })
})
