import React from 'react'
import { screen } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import IncludedWorks from 'panels/IncludedWorks'
import { fetchMissingBookIndexEntries } from 'store/books/actions'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('components/books/BookIndexEntry', () => ({
  default: ({ id }) => <div data-testid={`book-${id}`} />,
}))

vi.mock('hooks/useFittedSize', () => ({
  default: () => [{ current: null }, 'lg'],
}))

vi.mock('store/books/actions', async() => {
  const actual = await vi.importActual('store/books/actions')
  return {
    ...actual,
    fetchMissingBookIndexEntries: vi.fn(() => () => undefined),
  }
})

const stateFor = details => ({
  axis: {
    currentAuthorId: null,
    currentBookId: 5,
    currentTagId: null,
    seed: null,
  },
  storeBooks: {
    bookDetailsCurrent: details,
    booksIndex: {
      5: {
        id: 5,
        title: 'Collected Stories',
        authorIds: [1],
        format: 'collection',
      },
    },
    booksRefs: {},
    requestedBookId: null,
  },
})

describe('IncludedWorks', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.stubGlobal('ResizeObserver', vi.fn(() => ({
      observe: vi.fn(),
      disconnect: vi.fn(),
    })))
  })

  it('renders nothing unless the current book is a collection', () => {
    const { container: novel } = renderWithProviders(<IncludedWorks />, {
      preloadedState: stateFor({ id: 5, format: 'big', collectedWorkIds: [8] }),
    })
    expect(novel).toBeEmptyDOMElement()

    const { container: otherBook } = renderWithProviders(<IncludedWorks />, {
      preloadedState: stateFor({ id: 4, format: 'collection', collectedWorkIds: [8] }),
    })
    expect(otherBook).toBeEmptyDOMElement()
    expect(fetchMissingBookIndexEntries).not.toHaveBeenCalled()
  })

  it('renders included works and loads their covers', () => {
    renderWithProviders(<IncludedWorks />, {
      preloadedState: stateFor({
        id: 5,
        format: 'collection',
        collectedWorkIds: [8, 9],
      }),
    })

    expect(screen.getByLabelText('Included works')).toHaveClass('panel--included-works')
    expect(screen.getByText('Included works')).toBeInTheDocument()
    expect(screen.getByText('2')).toBeInTheDocument()
    expect(screen.getByTestId('book-8')).toBeInTheDocument()
    expect(screen.getByTestId('book-9')).toBeInTheDocument()
    expect(fetchMissingBookIndexEntries).toHaveBeenCalledWith([8, 9])
  })

  it('shows an empty list for a collection with no works', () => {
    renderWithProviders(<IncludedWorks />, {
      preloadedState: stateFor({ id: 5, format: 'collection', collectedWorkIds: [] }),
    })

    expect(screen.getByText('Included works')).toBeInTheDocument()
    expect(screen.getByText('No books')).toBeInTheDocument()
    expect(fetchMissingBookIndexEntries).not.toHaveBeenCalled()
  })
})
