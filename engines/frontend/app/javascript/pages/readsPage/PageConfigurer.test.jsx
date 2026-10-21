import React from 'react'
import { waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import PageConfigurer from 'pages/readsPage/PageConfigurer'
import apiClient from 'store/books/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/books/apiClient', () => ({
  default: {
    getBooksIndex: vi.fn(),
    getBooksRefs: vi.fn(),
  },
}))

vi.mock('store/navbar/actions', () => ({
  prepareNavRefs: () => () => Promise.resolve(),
}))

vi.mock('store/coverDesigns/actions', () => ({
  fetchCoverDesigns: () => () => Promise.resolve(),
}))

const leftoverList = {
  bookIds: [4, 5],
  booksTotal: 2,
  listFilter: { years: [2000] },
  page: 3,
  perPage: 1000,
  sortBy: 'year',
}

describe('Reads PageConfigurer', () => {
  beforeEach(() => {
    apiClient.getBooksRefs.mockReset()
    apiClient.getBooksIndex.mockReset()
    apiClient.getBooksRefs.mockResolvedValue({
      books: [{ id: 8, year: 1990 }],
      total: 1,
    })
    apiClient.getBooksIndex.mockResolvedValue([])
  })

  it('loads the current user reads when page and sort are absent from the url', async() => {
    const { store } = renderWithProviders(<PageConfigurer />, {
      preloadedState: { booksList: leftoverList },
      urlStore: {
        pageState: { page: null, sortBy: null },
      },
    })

    await waitFor(() => expect(apiClient.getBooksRefs).toHaveBeenCalledWith({
      page: 1,
      perPage: 40,
      read: true,
      sortBy: 'random',
    }))
    await waitFor(() => expect(store.getState().booksList.bookIds).toEqual([8]))
    expect(store.getState().booksList.listFilter).toEqual({ read: true })
  })

  it('uses page and sort from the url', async() => {
    renderWithProviders(<PageConfigurer />, {
      preloadedState: { booksList: leftoverList },
      urlStore: {
        pageState: { page: 2, sortBy: 'latest' },
      },
    })

    await waitFor(() => expect(apiClient.getBooksRefs).toHaveBeenCalledWith({
      page: 2,
      perPage: 40,
      read: true,
      sortBy: 'latest',
    }))
  })
})
