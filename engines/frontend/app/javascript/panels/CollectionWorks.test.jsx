import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import CollectionWorks from 'panels/CollectionWorks'
import { setCurrentBookId } from 'store/axis/actions'
import { fetchMissingBookIndexEntries } from 'store/books/actions'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('components/books/BookIndexEntry', () => ({
  default: ({ id, onSelect, selectedId }) => (
    <button
      data-selected={selectedId === id ? 'yes' : 'no'}
      data-testid={`book-${id}`}
      // The mock has to forward the id from this render into the click.
      // eslint-disable-next-line react/jsx-no-bind
      onClick={() => { if (onSelect) onSelect(id) }}
      type='button'
    />
  ),
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

describe('CollectionWorks', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.stubGlobal('ResizeObserver', vi.fn(() => ({
      observe: vi.fn(),
      disconnect: vi.fn(),
    })))
  })

  it('renders nothing unless the current book is a collection', () => {
    const { container: novel } = renderWithProviders(<CollectionWorks />, {
      preloadedState: stateFor({ id: 5, format: 'big', collectedWorkIds: [8] }),
    })
    expect(novel).toBeEmptyDOMElement()

    const { container: otherBook } = renderWithProviders(<CollectionWorks />, {
      preloadedState: stateFor({ id: 4, format: 'collection', collectedWorkIds: [8] }),
    })
    expect(otherBook).toBeEmptyDOMElement()
    expect(fetchMissingBookIndexEntries).not.toHaveBeenCalled()
  })

  it('renders included works and loads their covers', () => {
    renderWithProviders(<CollectionWorks />, {
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
    renderWithProviders(<CollectionWorks />, {
      preloadedState: stateFor({ id: 5, format: 'collection', collectedWorkIds: [] }),
    })

    expect(screen.getByText('Included works')).toBeInTheDocument()
    expect(screen.getByText('No books')).toBeInTheDocument()
    expect(fetchMissingBookIndexEntries).not.toHaveBeenCalled()
  })

  it('selects an included work without changing the current book', async() => {
    const user = userEvent.setup()
    const showIncludedWork = vi.fn()

    renderWithProviders(<CollectionWorks />, {
      preloadedState: stateFor({
        id: 5,
        format: 'collection',
        collectedWorkIds: [8, 9],
      }),
      urlStore: {
        actions: { showIncludedWork },
        pageState: { includedWorkId: 9 },
      },
    })

    expect(screen.getByTestId('book-9')).toHaveAttribute('data-selected', 'yes')
    expect(screen.getByTestId('book-8')).toHaveAttribute('data-selected', 'no')

    await user.click(screen.getByTestId('book-8'))
    expect(showIncludedWork).toHaveBeenCalledWith(8)
  })

  it('clears an included work the current book does not contain', () => {
    const showIncludedWork = vi.fn()

    renderWithProviders(<CollectionWorks />, {
      preloadedState: stateFor({ id: 5, format: 'collection', collectedWorkIds: [9] }),
      urlStore: {
        actions: { showIncludedWork },
        pageState: { includedWorkId: 8 },
      },
    })

    expect(showIncludedWork).toHaveBeenCalledWith(null)
  })

  it('keeps the included work until the current book details are loaded', () => {
    const showIncludedWork = vi.fn()

    renderWithProviders(<CollectionWorks />, {
      preloadedState: stateFor({ id: 4, format: 'big', collectedWorkIds: [] }),
      urlStore: {
        actions: { showIncludedWork },
        pageState: { includedWorkId: 8 },
      },
    })

    expect(showIncludedWork).not.toHaveBeenCalled()
  })

  it('clears the included work when another book is selected', async() => {
    const showIncludedWork = vi.fn()
    const { store } = renderWithProviders(<CollectionWorks />, {
      preloadedState: stateFor({
        id: 5,
        format: 'collection',
        collectedWorkIds: [8],
      }),
      urlStore: {
        actions: { showIncludedWork },
        pageState: { includedWorkId: 8 },
      },
    })

    expect(showIncludedWork).not.toHaveBeenCalled()
    store.dispatch(setCurrentBookId(6))

    await waitFor(() => expect(showIncludedWork).toHaveBeenCalledWith(null))
  })
})
