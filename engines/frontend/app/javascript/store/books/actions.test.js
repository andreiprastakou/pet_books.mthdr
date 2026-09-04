import { configureStore } from '@reduxjs/toolkit'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import axisReducer from 'store/axis/slice'
import { setCurrentBookId } from 'store/axis/actions'
import booksReducer from 'store/books/slice'
import {
  fetchCurrentBookDetails,
  fetchMissingBookIndexEntries,
  showBook,
} from 'store/books/actions'
import apiClient from 'store/books/apiClient'

vi.mock('store/books/apiClient', () => ({
  default: {
    getBookFull: vi.fn(),
    getBooksIndex: vi.fn(),
  },
}))

const makeStore = preloadedState => configureStore({
  reducer: {
    axis: axisReducer,
    storeBooks: booksReducer,
  },
  preloadedState,
})

describe('books actions', () => {
  beforeEach(() => {
    apiClient.getBookFull.mockReset()
    apiClient.getBooksIndex.mockReset()
  })

  it('skips fetching details when there is no current book', async() => {
    const store = makeStore()
    await store.dispatch(fetchCurrentBookDetails())

    expect(apiClient.getBookFull).not.toHaveBeenCalled()
  })

  it('fetches and stores current book details', async() => {
    const details = { id: 7, title: 'War and Peace' }
    apiClient.getBookFull.mockResolvedValue(details)

    const store = makeStore()
    store.dispatch(setCurrentBookId(7))
    await store.dispatch(fetchCurrentBookDetails())

    expect(apiClient.getBookFull).toHaveBeenCalledWith(7)
    expect(store.getState().storeBooks.bookDetailsCurrent).toEqual(details)
  })

  it('requests a different book when showing a known ref', () => {
    const store = makeStore({
      axis: { currentBookId: 1, currentAuthorId: null, currentTagId: null, seed: null },
      storeBooks: {
        booksIndex: {},
        booksRefs: { 2: { id: 2, year: 1900 } },
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
    })

    store.dispatch(showBook(2))
    expect(store.getState().storeBooks.requestedBookId).toBe(2)
  })

  it('does not request the already current book', () => {
    const store = makeStore({
      axis: { currentBookId: 2, currentAuthorId: null, currentTagId: null, seed: null },
      storeBooks: {
        booksIndex: {},
        booksRefs: { 2: { id: 2, year: 1900 } },
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
    })

    store.dispatch(showBook(2))
    expect(store.getState().storeBooks.requestedBookId).toBeNull()
  })

  it('throws when showing a missing or empty book id', () => {
    const store = makeStore()
    expect(() => store.dispatch(showBook(null))).toThrow('Trying to show nothing!')
    expect(() => store.dispatch(showBook(99))).toThrow('Book #99 is missing!')
  })

  it('fetches only missing book index entries in batches of 50', async() => {
    const existingIds = [1]
    const requestedIds = Array.from({ length: 52 }, (_, i) => i + 1)
    apiClient.getBooksIndex.mockImplementation(({ ids }) =>
      Promise.resolve(ids.map(id => ({ id, title: `Book ${id}` })))
    )

    const store = makeStore({
      storeBooks: {
        booksIndex: { 1: { id: 1 } },
        booksRefs: {},
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
    })

    await store.dispatch(fetchMissingBookIndexEntries(requestedIds))

    expect(apiClient.getBooksIndex).toHaveBeenCalledTimes(2)
    expect(apiClient.getBooksIndex.mock.calls[0][0].ids).toHaveLength(50)
    expect(apiClient.getBooksIndex.mock.calls[1][0].ids).toEqual([52])
    expect(store.getState().storeBooks.booksIndex[52]).toEqual({ id: 52, title: 'Book 52' })
    expect(existingIds).toEqual([1])
  })

  it('skips the API when all requested index entries are loaded', async() => {
    const store = makeStore({
      storeBooks: {
        booksIndex: { 1: { id: 1 }, 2: { id: 2 } },
        booksRefs: {},
        bookDetailsCurrent: {},
        requestedBookId: null,
      },
    })

    await store.dispatch(fetchMissingBookIndexEntries([1, 2]))
    expect(apiClient.getBooksIndex).not.toHaveBeenCalled()
  })
})
