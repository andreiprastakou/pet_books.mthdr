import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/books/slice'
import {
  selectBookRef,
  selectBooksIndexEntry,
  selectBooksIndexIds,
  selectCurrentBookDetails,
  selectCurrentBookIndexEntry,
  selectCurrentBookRef,
  selectRequestedBookId,
} from 'store/books/selectors'

const {
  addBook,
  addBooks,
  addBooksRefs,
  clearBooksRefs,
  setCurrentBookDetails,
  setRequestedBookId,
} = slice.actions

describe('books slice', () => {
  it('has an empty initial state', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      booksIndex: {},
      booksRefs: {},
      bookDetailsCurrent: {},
      requestedBookId: null,
    })
  })

  it('adds a single book and batches of books into the index', () => {
    let state = reducer(undefined, addBook({ id: 1, title: 'One' }))
    state = reducer(state, addBooks([{ id: 2, title: 'Two' }, { id: 3, title: 'Three' }]))

    expect(state.booksIndex).toEqual({
      1: { id: 1, title: 'One' },
      2: { id: 2, title: 'Two' },
      3: { id: 3, title: 'Three' },
    })
  })

  it('merges and clears book refs', () => {
    let state = reducer(undefined, addBooksRefs([
      { id: 1, year: 1900 },
      { id: 2, year: 2000 },
    ]))
    expect(state.booksRefs).toEqual({
      1: { id: 1, year: 1900 },
      2: { id: 2, year: 2000 },
    })

    state = reducer(state, clearBooksRefs())
    expect(state.booksRefs).toEqual({})
  })

  it('sets current details and requested book id', () => {
    let state = reducer(undefined, setCurrentBookDetails({ id: 9, title: 'Now' }))
    state = reducer(state, setRequestedBookId(9))

    expect(state.bookDetailsCurrent).toEqual({ id: 9, title: 'Now' })
    expect(state.requestedBookId).toBe(9)
  })
})

describe('books selectors', () => {
  const state = {
    axis: { currentBookId: 2 },
    storeBooks: {
      booksIndex: { 1: { id: 1 }, 2: { id: 2, title: 'Current' } },
      booksRefs: { 2: { id: 2, year: 1999 } },
      bookDetailsCurrent: { id: 2, title: 'Details' },
      requestedBookId: 5,
    },
  }

  it('selects index entries, refs, details, and request id', () => {
    expect(selectCurrentBookDetails()(state)).toEqual({ id: 2, title: 'Details' })
    expect(selectBooksIndexEntry(1)(state)).toEqual({ id: 1 })
    expect(selectBooksIndexIds()(state)).toEqual([1, 2])
    expect(selectCurrentBookIndexEntry()(state)).toEqual({ id: 2, title: 'Current' })
    expect(selectBookRef(2)(state)).toEqual({ id: 2, year: 1999 })
    expect(selectCurrentBookRef()(state)).toEqual({ id: 2, year: 1999 })
    expect(selectRequestedBookId()(state)).toBe(5)
  })
})
