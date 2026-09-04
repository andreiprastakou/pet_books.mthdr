import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/authors/slice'
import {
  selectAuthorDefaultImageUrl,
  selectAuthorFull,
  selectAuthorsIndexEntriesByIds,
  selectAuthorsRefsByIds,
  selectAuthorsRefsLoaded,
} from 'store/authors/selectors'

const {
  addAuthorFull,
  addAuthorsIndexEntries,
  assignAuthorsIndex,
  assignAuthorsRefs,
  setDefaultAuthorImageUrl,
} = slice.actions

describe('authors slice', () => {
  it('has an empty unloaded initial state', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      authorsFull: {},
      authorsIndex: {},
      authorsRefs: {},
      defaultPhotoUrl: null,
      refsLoaded: false,
    })
  })

  it('stores a full author by id', () => {
    const author = { id: 5, fullname: 'Ada' }
    expect(reducer(undefined, addAuthorFull(author)).authorsFull).toEqual({ 5: author })
  })

  it('assigns and merges authors index entries', () => {
    const first = reducer(undefined, assignAuthorsIndex([
      { id: 1, fullname: 'A' },
      { id: 2, fullname: 'B' },
    ]))
    expect(first.authorsIndex).toEqual({
      1: { id: 1, fullname: 'A' },
      2: { id: 2, fullname: 'B' },
    })

    const merged = reducer(first, addAuthorsIndexEntries([{ id: 3, fullname: 'C' }]))
    expect(Object.keys(merged.authorsIndex)).toEqual(['1', '2', '3'])

    const replaced = reducer(merged, assignAuthorsIndex([{ id: 9, fullname: 'Z' }]))
    expect(replaced.authorsIndex).toEqual({ 9: { id: 9, fullname: 'Z' } })
  })

  it('indexes author refs and marks them loaded', () => {
    const refs = [{ id: 1, fullname: 'A' }, { id: 2, fullname: 'B' }]
    const state = reducer(undefined, assignAuthorsRefs(refs))

    expect(state.refsLoaded).toBe(true)
    expect(state.authorsRefs).toEqual({ 1: refs[0], 2: refs[1] })
  })

  it('sets the default author image url', () => {
    const state = reducer(undefined, setDefaultAuthorImageUrl('/default.png'))
    expect(state.defaultPhotoUrl).toBe('/default.png')
  })
})

describe('authors selectors', () => {
  const state = {
    storeAuthors: {
      authorsFull: { 1: { id: 1, fullname: 'Ada' } },
      authorsIndex: { 1: { id: 1 }, 2: { id: 2 } },
      authorsRefs: { 1: { id: 1, fullname: 'Ada' }, 2: { id: 2, fullname: 'Bob' } },
      defaultPhotoUrl: '/photo.png',
      refsLoaded: true,
    },
  }

  it('selects full author, index entries, refs, and defaults', () => {
    expect(selectAuthorFull(1)(state)).toEqual({ id: 1, fullname: 'Ada' })
    expect(selectAuthorsIndexEntriesByIds([2, 1])(state)).toEqual([{ id: 2 }, { id: 1 }])
    expect(selectAuthorsRefsByIds([1])(state)).toEqual([{ id: 1, fullname: 'Ada' }])
    expect(selectAuthorsRefsLoaded()(state)).toBe(true)
    expect(selectAuthorDefaultImageUrl()(state)).toBe('/photo.png')
  })
})
