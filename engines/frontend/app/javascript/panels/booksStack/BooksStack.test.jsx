import React from 'react'
import { cleanup, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import BooksListControls from 'panels/booksStack/BooksStack'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('panels/booksStack/BooksSpineStack', () => ({
  default: ({ bookIds }) => (
    <div data-testid='spine-stack'>
      { bookIds.join(',') }
    </div>
  ),
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

  const stackState = ({ currentBookId = 1, compactStack = true } = {}) => ({
    preloadedState: {
      axis: {
        currentAuthorId: null,
        currentBookId,
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
        booksIndex: {
          1: { id: 1, format: 'collection', collectedWorkIds: [2] },
          2: { id: 2, format: 'small', collectedWorkIds: [] },
          3: { id: 3, format: 'big', collectedWorkIds: [] },
        },
        booksRefs: {},
        requestedBookId: null,
      },
    },
    urlStore: {
      pageState: {
        activePanelId: 'books-stack',
        compactStack,
        registeredPanelIds: ['books-stack'],
      },
      actions: {
        activatePanel: vi.fn(),
        deactivatePanel: vi.fn(),
        registerPanel: vi.fn(),
        setCompactStack: vi.fn(),
        unregisterPanel: vi.fn(),
      },
    },
  })

  it('previews the other compact icon and labels the action', async() => {
    const user = userEvent.setup()
    renderWithProviders(<BooksListControls />, stackState())
    const collapsedToggle = screen.getByRole('button', { name: 'Show all works' })

    expect(collapsedToggle).toHaveAttribute('title', 'Show all works')
    expect(collapsedToggle.querySelector('svg')).toHaveAttribute('data-icon', 'eye-slash')

    await user.hover(collapsedToggle)
    expect(collapsedToggle.querySelector('svg')).toHaveAttribute('data-icon', 'eye')

    cleanup()
    renderWithProviders(<BooksListControls />, stackState({ compactStack: false }))
    const expandedToggle = screen.getByRole('button', { name: 'Compact view' })

    expect(expandedToggle).toHaveAttribute('title', 'Compact view')
    expect(expandedToggle.querySelector('svg')).toHaveAttribute('data-icon', 'eye')

    await user.hover(expandedToggle)
    expect(expandedToggle.querySelector('svg')).toHaveAttribute('data-icon', 'eye-slash')
  })

  it('excludes collections from the count and hides nested books while compact', () => {
    renderWithProviders(<BooksListControls />, stackState())

    expect(screen.getByText('2')).toBeInTheDocument()
    expect(screen.getByTestId('spine-stack')).toHaveTextContent('1,3')
    expect(screen.getByRole('button', { name: 'Show all works' })).toHaveAttribute(
      'aria-pressed',
      'true'
    )
  })

  it('shows every book when the stack is expanded', () => {
    renderWithProviders(<BooksListControls />, stackState({ compactStack: false }))

    expect(screen.getByTestId('spine-stack')).toHaveTextContent('1,2,3')
    expect(screen.getByRole('button', { name: 'Compact view' })).toHaveAttribute(
      'aria-pressed',
      'false'
    )
  })

  it('opens the stack without changing the selected collection', async() => {
    const user = userEvent.setup()
    const { urlStore } = renderWithProviders(<BooksListControls />, stackState())

    await user.click(screen.getByRole('button', { name: 'Show all works' }))

    expect(urlStore.actions.setCompactStack).toHaveBeenCalledWith(false, {})
  })

  it('selects the first collection and the hidden book when compacting', async() => {
    const user = userEvent.setup()
    const { urlStore } = renderWithProviders(
      <BooksListControls />,
      stackState({ compactStack: false, currentBookId: 2 })
    )

    await user.click(screen.getByRole('button', { name: 'Compact view' }))

    expect(urlStore.actions.setCompactStack).toHaveBeenCalledWith(true, {
      'book_id': 1,
      'included_work_id': 2,
    })
  })

  it('moves a selected nested book onto its collection while compact', () => {
    const { urlStore } = renderWithProviders(
      <BooksListControls />,
      stackState({ currentBookId: 2 })
    )

    expect(urlStore.actions.setCompactStack).toHaveBeenCalledWith(true, {
      'book_id': 1,
      'included_work_id': 2,
    })
  })

  it('skips nested books when moving the selection in the compact stack', async() => {
    const user = userEvent.setup()
    const { store } = renderWithProviders(<BooksListControls />, stackState())

    screen.getByLabelText('Books').focus()
    await user.keyboard('{ArrowDown}')

    expect(store.getState().storeBooks.requestedBookId).toBe(3)
  })
})
