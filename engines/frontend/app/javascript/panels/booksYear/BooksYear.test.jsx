import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import BooksYear, { buildBookMatrix, spiralPositions } from 'panels/booksYear/BooksYear'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('components/books/BookIndexEntry', () => ({
  default: ({ id }) => <div data-testid={`book-${id}`} />,
}))

vi.mock('panels/booksYear/GhostBooks', () => ({
  default: () => <div data-testid='ghost-books' />,
}))

vi.mock('panels/booksYear/YearControl', () => ({
  default: ({ value, years }) => (
    <div data-testid='year-control'>
      { `${value}:${years.join(',')}` }
    </div>
  ),
}))

vi.mock('store/booksList/actions', async() => {
  const actual = await vi.importActual('store/booksList/actions')
  return {
    ...actual,
    fetchBooks: vi.fn(() => () => Promise.resolve()),
  }
})

const titleForYear = year => `Books of ${year}`

describe('spiralPositions / buildBookMatrix', () => {
  it('builds a spiral starting at the origin', () => {
    expect(spiralPositions(1)).toEqual([[0, 0]])
    expect(spiralPositions(5)).toEqual([
      [0, 0],
      [1, 0],
      [1, 1],
      [0, 1],
      [-1, 1],
    ])
  })

  it('centers the selected book and maps coordinates', () => {
    const matrix = buildBookMatrix([10, 20, 30], 20)

    expect(matrix.orderedBookIds).toEqual([20, 10, 30])
    expect(matrix.coordinatesById[20]).toEqual([0, 0])
    expect(matrix.idsByCoordinate['0:0']).toBe(20)
    expect(matrix.idsByCoordinate['1:0']).toBe(10)
    expect(matrix.idsByCoordinate['1:1']).toBe(30)
  })
})

describe('BooksYear', () => {
  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', vi.fn(function ResizeObserver(callback) {
      this.observe = () => callback()
      this.disconnect = vi.fn()
    }))
  })

  it('renders title, year control, and moves selection with arrows', async() => {
    const user = userEvent.setup()

    const { store } = renderWithProviders(
      <BooksYear title={titleForYear} />,
      {
        preloadedState: {
          axis: {
            currentAuthorId: null,
            currentBookId: 10,
            currentTagId: null,
            seed: null,
          },
          booksList: {
            bookIds: [10, 20, 30],
            booksTotal: 3,
            listFilter: { years: [2000] },
            page: 1,
            perPage: 16,
            sortBy: 'name',
          },
          booksYears: {
            years: [1990, 2000, 2010],
          },
        },
        urlStore: {
          pageState: {
            activePanelId: 'books-list-yearly',
            registeredPanelIds: ['books-list-yearly'],
          },
          actions: {
            activatePanel: vi.fn(),
            deactivatePanel: vi.fn(),
            registerPanel: vi.fn(),
            unregisterPanel: vi.fn(),
          },
        },
      }
    )

    expect(screen.getByText('Books of 2000')).toBeInTheDocument()
    expect(screen.getByTestId('year-control')).toHaveTextContent('2000:1990,2000,2010')
    expect(screen.getByText('3')).toBeInTheDocument()

    const panel = screen.getByLabelText('All books')
    panel.focus()
    await user.keyboard('{ArrowRight}')

    // selected 10 at [0,0]; right neighbor is [1,0] => 20
    expect(store.getState().storeBooks.requestedBookId).toBe(20)
  })
})
