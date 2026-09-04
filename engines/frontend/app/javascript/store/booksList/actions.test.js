import { configureStore } from '@reduxjs/toolkit'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import axisReducer from 'store/axis/slice'
import booksReducer from 'store/books/slice'
import booksListReducer from 'store/booksList/slice'
import {
  assignBookIds,
  assignFilter,
  assignPage,
  clearListState,
  fetchBooks,
  setupBooksListSelection,
  shiftSelection,
  switchToFirstBook,
} from 'store/booksList/actions'
import { setCurrentBookId } from 'store/axis/actions'
import apiClient from 'store/books/apiClient'

vi.mock('store/books/apiClient', () => ({
  default: {
    getBooksRefs: vi.fn(),
    getBooksIndex: vi.fn(),
  },
}))

const makeStore = preloadedState => configureStore({
  reducer: {
    axis: axisReducer,
    storeBooks: booksReducer,
    booksList: booksListReducer,
  },
  preloadedState,
})

describe('booksList actions', () => {
  beforeEach(() => {
    apiClient.getBooksRefs.mockReset()
    apiClient.getBooksIndex.mockReset()
  })

  it('fetches books refs and missing index entries', async() => {
    const books = [
      { id: 1, year: 1900 },
      { id: 2, year: 2000 },
    ]
    apiClient.getBooksRefs.mockResolvedValue({ books, total: 2 })
    apiClient.getBooksIndex.mockResolvedValue([
      { id: 1, title: 'One' },
      { id: 2, title: 'Two' },
    ])

    const store = makeStore()
    store.dispatch(assignFilter({ authorId: 9 }))
    store.dispatch(assignPage(2))
    await store.dispatch(fetchBooks())

    expect(apiClient.getBooksRefs).toHaveBeenCalledWith({
      authorId: 9,
      page: 2,
      perPage: 16,
      sortBy: 'name',
    })
    expect(store.getState().booksList.bookIds).toEqual([1, 2])
    expect(store.getState().booksList.booksTotal).toBe(2)
    expect(store.getState().storeBooks.booksRefs).toEqual({
      1: books[0],
      2: books[1],
    })
    expect(apiClient.getBooksIndex).toHaveBeenCalled()
  })

  it('does not fetch index entries for an empty result set', async() => {
    apiClient.getBooksRefs.mockResolvedValue({ books: [], total: 0 })

    const store = makeStore()
    await store.dispatch(fetchBooks())

    expect(store.getState().booksList.bookIds).toEqual([])
    expect(apiClient.getBooksIndex).not.toHaveBeenCalled()
  })

  it('shifts selection with wraparound', () => {
    const store = makeStore({
      axis: { currentBookId: 2, currentAuthorId: null, currentTagId: null, seed: null },
      storeBooks: {
        booksIndex: {},
        booksRefs: {
          1: { id: 1 },
          2: { id: 2 },
          3: { id: 3 },
        },
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
      booksList: {
        bookIds: [1, 2, 3],
        booksTotal: 3,
        listFilter: {},
        sortBy: 'name',
        page: 1,
        perPage: 16,
      },
    })

    store.dispatch(shiftSelection(1))
    expect(store.getState().storeBooks.requestedBookId).toBe(3)

    store.dispatch(setCurrentBookId(3))
    store.dispatch(shiftSelection(1))
    expect(store.getState().storeBooks.requestedBookId).toBe(1)

    store.dispatch(setCurrentBookId(1))
    store.dispatch(shiftSelection(-1))
    expect(store.getState().storeBooks.requestedBookId).toBe(3)
  })

  it('switches to the first book when current is outside the list', () => {
    const store = makeStore({
      axis: { currentBookId: 99, currentAuthorId: null, currentTagId: null, seed: null },
      booksList: {
        bookIds: [4, 5],
        booksTotal: 2,
        listFilter: {},
        sortBy: 'name',
        page: 1,
        perPage: 16,
      },
    })

    store.dispatch(switchToFirstBook())
    expect(store.getState().storeBooks.requestedBookId).toBe(4)
  })

  it('keeps the current book when it is already in the list', () => {
    const store = makeStore({
      axis: { currentBookId: 5, currentAuthorId: null, currentTagId: null, seed: null },
      storeBooks: {
        booksIndex: {},
        booksRefs: {},
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
      booksList: {
        bookIds: [4, 5],
        booksTotal: 2,
        listFilter: {},
        sortBy: 'name',
        page: 1,
        perPage: 16,
      },
    })

    store.dispatch(switchToFirstBook())
    expect(store.getState().storeBooks.requestedBookId).toBeNull()
  })

  it('shows the current book ref during list setup', () => {
    const store = makeStore({
      axis: { currentBookId: 2, currentAuthorId: null, currentTagId: null, seed: null },
      storeBooks: {
        booksIndex: {},
        booksRefs: { 2: { id: 2 } },
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
      booksList: {
        bookIds: [1, 2],
        booksTotal: 2,
        listFilter: {},
        sortBy: 'name',
        page: 1,
        perPage: 16,
      },
    })

    store.dispatch(setupBooksListSelection())
    expect(store.getState().storeBooks.requestedBookId).toBeNull()
  })

  it('falls back to the first book when setup has no current ref', () => {
    const store = makeStore({
      axis: { currentBookId: null, currentAuthorId: null, currentTagId: null, seed: null },
      storeBooks: {
        booksIndex: {},
        booksRefs: {},
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
      booksList: {
        bookIds: [8, 9],
        booksTotal: 2,
        listFilter: {},
        sortBy: 'name',
        page: 1,
        perPage: 16,
      },
    })

    store.dispatch(setupBooksListSelection())
    expect(store.getState().storeBooks.requestedBookId).toBe(8)
  })

  it('clears list state', () => {
    const store = makeStore()
    store.dispatch(assignBookIds([1, 2]))
    store.dispatch(clearListState())
    expect(store.getState().booksList.bookIds).toEqual([])
  })
})
