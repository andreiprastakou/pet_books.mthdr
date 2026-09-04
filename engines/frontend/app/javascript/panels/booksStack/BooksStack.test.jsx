import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import BooksListControls from 'panels/booksStack/BooksStack'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('panels/booksStack/BooksSpineStack', () => ({
  default: () => <div data-testid='spine-stack' />,
}))

vi.mock('panels/booksStack/SortingDropdown', () => ({
  default: () => <div data-testid='sorting-dropdown' />,
}))

describe('BooksStack', () => {
  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', vi.fn(() => ({
      observe: vi.fn(),
      disconnect: vi.fn(),
    })))
  })

  it('shows the total count and shifts selection with arrow keys when active', async() => {
    const user = userEvent.setup()

    const { store } = renderWithProviders(<BooksListControls />, {
      preloadedState: {
        axis: {
          currentAuthorId: null,
          currentBookId: 2,
          currentTagId: null,
          seed: null,
        },
        booksList: {
          bookIds: [1, 2, 3],
          booksTotal: 3,
          listFilter: {},
          page: 1,
          perPage: 16,
          sortBy: 'name',
        },
        storeBooks: {
          bookDetailsCurrent: {},
          booksIndex: {},
          booksRefs: {
            1: { id: 1 },
            2: { id: 2 },
            3: { id: 3 },
          },
          requestedBookId: null,
        },
      },
      urlStore: {
        pageState: {
          activePanelId: 'books-stack',
          registeredPanelIds: ['books-stack'],
        },
        actions: {
          activatePanel: vi.fn(),
          deactivatePanel: vi.fn(),
          registerPanel: vi.fn(),
          unregisterPanel: vi.fn(),
        },
      },
    })

    expect(screen.getByText('All Works')).toBeInTheDocument()
    expect(screen.getByText('3')).toBeInTheDocument()

    const panel = screen.getByLabelText('Books')
    panel.focus()
    await user.keyboard('{ArrowDown}')

    expect(store.getState().storeBooks.requestedBookId).toBe(3)
  })
})
