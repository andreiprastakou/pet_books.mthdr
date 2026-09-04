import React from 'react'
import { screen } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import AuthorsList, { handleAuthorsKeyDown } from 'panels/authorsList/AuthorsList'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('panels/authorsList/AuthorsListItem', () => ({
  default: ({ author }) => <div data-testid={`author-${author.id}`} />,
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

describe('handleAuthorsKeyDown', () => {
  const authors = [
    { id: 1, fullname: 'A' },
    { id: 2, fullname: 'B' },
    { id: 3, fullname: 'C' },
  ]

  it('moves right within the page', () => {
    const showAuthor = vi.fn()
    const event = {
      key: 'ArrowRight',
      preventDefault: vi.fn(),
      stopPropagation: vi.fn(),
    }

    expect(handleAuthorsKeyDown(event, {
      authors,
      authorPagePath: id => `/authors/${id}`,
      page: 1,
      perPage: 16,
      selectedAuthorId: 1,
      showAuthor,
      switchToIndexPage: vi.fn(),
      totalCount: 3,
    })).toBeNull()

    expect(showAuthor).toHaveBeenCalledWith(2)
    expect(event.preventDefault).toHaveBeenCalled()
  })

  it('pages down and returns a pending target', () => {
    const switchToIndexPage = vi.fn()
    const event = {
      key: 'PageDown',
      preventDefault: vi.fn(),
      stopPropagation: vi.fn(),
    }

    const pending = handleAuthorsKeyDown(event, {
      authors,
      authorPagePath: id => `/authors/${id}`,
      page: 1,
      perPage: 2,
      selectedAuthorId: 1,
      showAuthor: vi.fn(),
      switchToIndexPage,
      totalCount: 5,
    })

    expect(switchToIndexPage).toHaveBeenCalledWith(2, 2)
    expect(pending).toEqual({ index: 0, page: 2 })
  })

  it('navigates to the author page on Enter', () => {
    const assign = vi.fn()
    vi.stubGlobal('location', { assign })
    const event = {
      key: 'Enter',
      preventDefault: vi.fn(),
      stopPropagation: vi.fn(),
    }

    handleAuthorsKeyDown(event, {
      authors,
      authorPagePath: id => `/authors/${id}`,
      page: 1,
      perPage: 16,
      selectedAuthorId: 2,
      showAuthor: vi.fn(),
      switchToIndexPage: vi.fn(),
      totalCount: 3,
    })

    expect(assign).toHaveBeenCalledWith('/authors/2')
    vi.unstubAllGlobals()
  })
})

describe('AuthorsList', () => {
  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', vi.fn(() => ({
      observe: vi.fn(),
      disconnect: vi.fn(),
    })))
  })

  it('renders the count badge and author items', () => {
    renderWithProviders(<AuthorsList />, {
      preloadedState: {
        authorsPage: {
          authorIds: [1, 2],
          authorsTotal: 2,
          listFilter: {},
          page: 1,
          perPage: 40,
          sortBy: 'name',
        },
        storeAuthors: {
          authorsFull: {},
          authorsIndex: {
            1: { id: 1, fullname: 'Ada' },
            2: { id: 2, fullname: 'Bob' },
          },
          authorsRefs: {},
          defaultPhotoUrl: null,
          refsLoaded: true,
        },
      },
      urlStore: {
        pageState: {
          activePanelId: 'authors-list',
          registeredPanelIds: ['authors-list'],
          sortOrder: 'name',
        },
        actions: {
          activatePanel: vi.fn(),
          deactivatePanel: vi.fn(),
          registerPanel: vi.fn(),
          unregisterPanel: vi.fn(),
          showAuthor: vi.fn(),
          switchToIndexPage: vi.fn(),
        },
      },
    })

    expect(screen.getByText('All Authors')).toBeInTheDocument()
    expect(screen.getByText('2')).toBeInTheDocument()
    expect(screen.getByTestId('author-1')).toBeInTheDocument()
    expect(screen.getByTestId('author-2')).toBeInTheDocument()
  })
})
