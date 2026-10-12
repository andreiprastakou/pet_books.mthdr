import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import BooksListCovers from 'panels/BooksListCovers'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('components/books/BookIndexEntry', () => ({
  default: ({ id }) => <div data-testid={`book-${id}`} />,
}))

vi.mock('components/Pagination', () => ({
  default: () => null,
}))

vi.mock('components/SortingDropdown', () => ({
  default: () => null,
}))

vi.mock('hooks/useFittedSize', () => ({
  default: () => [{ current: null }, 'lg'],
}))

const panelUrlStore = (overrides = {}) => ({
  pageState: {
    activePanelId: 'books-list-covers',
    registeredPanelIds: ['books-list-covers'],
  },
  actions: {
    activatePanel: vi.fn(),
    deactivatePanel: vi.fn(),
    registerPanel: vi.fn(),
    unregisterPanel: vi.fn(),
    switchToIndexPage: vi.fn(),
  },
  ...overrides,
})

describe('BooksListCovers', () => {
  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', vi.fn(() => ({
      observe: vi.fn(),
      disconnect: vi.fn(),
    })))
  })

  it('renders an empty state and header counter', () => {
    renderWithProviders(
      <BooksListCovers header='Tagged books' />,
      {
        preloadedState: {
          booksList: {
            bookIds: [],
            booksTotal: 0,
            listFilter: {},
            page: 1,
            perPage: 16,
            sortBy: 'title',
          },
        },
        urlStore: panelUrlStore(),
      }
    )

    expect(screen.getByText('Tagged books')).toBeInTheDocument()
    expect(screen.getByText('No books')).toBeInTheDocument()
  })

  it('moves selection with arrow keys when active', async() => {
    const user = userEvent.setup()

    const { store } = renderWithProviders(
      <BooksListCovers header='Books' />,
      {
        preloadedState: {
          axis: {
            currentAuthorId: null,
            currentBookId: 1,
            currentTagId: null,
            seed: null,
          },
          booksList: {
            bookIds: [1, 2, 3, 4],
            booksTotal: 4,
            listFilter: {},
            page: 1,
            perPage: 16,
            sortBy: 'title',
          },
        },
        urlStore: panelUrlStore(),
      }
    )

    expect(screen.getByText('4')).toBeInTheDocument()
    const panel = screen.getByLabelText('Books')
    panel.focus()
    await user.keyboard('{ArrowRight}')

    expect(store.getState().storeBooks.requestedBookId).toBe(2)
  })

  it('renders a provided book list instead of the page list', () => {
    const { store } = renderWithProviders(
      <BooksListCovers
        bookIds={[8, 9]}
        header='Included works'
        showControls={false}
      />,
      {
        preloadedState: {
          axis: {
            currentAuthorId: null,
            currentBookId: 1,
            currentTagId: null,
            seed: null,
          },
          booksList: {
            bookIds: [1, 2],
            booksTotal: 2,
            listFilter: {},
            page: 1,
            perPage: 16,
            sortBy: 'title',
          },
        },
        urlStore: panelUrlStore(),
      }
    )

    expect(screen.getByText('Included works')).toBeInTheDocument()
    expect(screen.getByTestId('book-8')).toBeInTheDocument()
    expect(screen.getByTestId('book-9')).toBeInTheDocument()
    expect(screen.queryByTestId('book-1')).not.toBeInTheDocument()
    expect(store.getState().axis.currentBookId).toBe(1)
    expect(store.getState().storeBooks.requestedBookId).toBeNull()
  })
})
