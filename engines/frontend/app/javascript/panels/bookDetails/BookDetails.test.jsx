import React from 'react'
import { act, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { MemoryRouter } from 'react-router-dom'

import BookDetails from 'panels/bookDetails/BookDetails'
import { setCurrentBookId } from 'store/axis/actions'
import { addBooks, fetchBookDetails, fetchCurrentBookDetails, setCurrentBookDetails } from 'store/books/actions'
import { renderWithProviders } from 'test/renderWithProviders'
import { buildPath } from 'store/urlStore/RootStoreProvider'

vi.mock('store/books/actions', async() => {
  const actual = await vi.importActual('store/books/actions')
  return {
    ...actual,
    fetchBookDetails: vi.fn(() => () => undefined),
    fetchCurrentBookDetails: vi.fn(() => () => undefined),
  }
})

vi.mock('components/Book', () => ({
  default: ({ bookIndexEntry, scrollIntoView = true, size = 'lg' }) => (
    <div
      data-scroll-into-view={scrollIntoView ? 'yes' : 'no'}
      data-size={size}
      data-testid='book-cover'
    >
      { bookIndexEntry.title }
    </div>
  ),
}))

const bookIndexEntry = {
  authorIds: [1], coverDesignId: 9, id: 5, title: 'Dune', year: 1965,
}

const bookDetails = {
  id: 5, title: 'Dune', yearPublished: 1965,
  formLabel: 'a science fiction novel',
  summary: 'Sandworms.',
  summarySource: 'warhammer.com',
  externalLinks: [
    { 'external_resource': 'wikipedia', label: 'Wikipedia', url: 'https://en.wikipedia.org/wiki/Dune' },
    { 'external_resource': 'goodreads', label: 'Goodreads', url: 'https://goodreads.com/dune' },
  ],
  tagIds: [11],
  publicLists: [
    {
      publicListId: 2,
      publicListTypeId: 8,
      publicListTypeName: 'Nebula',
      publicListYear: 1966,
      bookRole: 'nominee',
    },
    {
      publicListId: 1,
      publicListTypeId: 7,
      publicListTypeName: 'Hugo',
      publicListYear: 1966,
      bookRole: 'winner',
    },
  ],
}

const routes = {
  authorPagePath: id => `/authors/${id}`,
  booksPagePath: ({ bookId } = {}) => (bookId ? `/books/${bookId}` : '/books'),
  bookPagePath: id => `/books/${id}`,
  listPagePath: (id, { bookId, listId } = {}) =>
    buildPath({ path: `/public-lists/${id}`, params: { 'book_id': bookId, 'list_id': listId } }),
  seriesPagePath: id => `/series/${id}`,
}

const baseState = {
  axis: {
    currentAuthorId: null,
    currentBookId: 5,
    currentTagId: null,
    seed: null,
  },
  storeAuthors: {
    authorsFull: {},
    authorsIndex: {},
    authorsRefs: { 1: { id: 1, fullname: 'Frank Herbert' } },
    defaultPhotoUrl: null,
    refsLoaded: true,
  },
  storeBooks: {
    bookDetailsCurrent: bookDetails,
    booksIndex: { 5: bookIndexEntry },
    booksRefs: {},
    requestedBookId: null,
  },
  storeCoverDesigns: {
    coverDesigns: {
      9: {
        id: 9,
        coverImage: 'default',
        titleFont: 'serif',
        titleColor: 'dark',
        authorNameFont: 'serif',
        authorNameColor: 'dark',
      },
    },
    coverDesignsLoaded: true,
  },
  storeTags: {
    categories: {},
    refsLoaded: true,
    tagsCategoriesIndex: {},
    tagsIndex: {},
    tagsRefs: { 11: { id: 11, name: 'fiction' } },
  },
}

describe('BookDetails', () => {
  const { matchMedia } = window

  beforeEach(() => {
    vi.clearAllMocks()
    window.matchMedia = matchMedia
  })

  it('renders nothing when details are missing or routes are not ready', () => {
    const { container: empty } = renderWithProviders(<BookDetails />, {
      preloadedState: {
        ...baseState,
        storeBooks: { ...baseState.storeBooks, bookDetailsCurrent: {} },
      },
    })
    expect(empty).toBeEmptyDOMElement()

    const { container: notReady } = renderWithProviders(<BookDetails />, {
      preloadedState: baseState,
      urlStore: { routesReady: false },
    })
    expect(notReady).toBeEmptyDOMElement()
  })

  it('renders details, links, tags, and can hide the cover', () => {
    renderWithProviders(<BookDetails showCover={false} />, {
      preloadedState: baseState,
      urlStore: { routes },
    })

    expect(screen.getByRole('heading', { name: 'Dune' })).toBeInTheDocument()
    expect(screen.getByText('a science fiction novel')).toBeInTheDocument()
    expect(screen.getByText('Sandworms.')).toBeInTheDocument()
    expect(document.querySelector('.book-details-panel-main-info .book-details-panel-annotation')).toBeInTheDocument()
    expect(screen.getByText('(source: warhammer.com)')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Frank Herbert' })).toHaveAttribute('href', '/authors/1')
    expect(screen.getByRole('button', { name: /wikipedia/iu })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /goodreads/iu })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Hugo' })).toHaveAttribute('href', '/public-lists/7?book_id=5&list_id=1')
    expect(screen.getByRole('link', { name: 'Nebula' })).toHaveAttribute('href', '/public-lists/8?book_id=5&list_id=2')
    expect(screen.getByRole('link', { name: '#fiction' })).toBeInTheDocument()
    expect(screen.queryByTestId('book-cover')).not.toBeInTheDocument()

    const publicLists = screen.getByRole('link', { name: 'Hugo' }).closest('.book-details-panel-public-lists')
    expect(publicLists).toHaveTextContent('1966: Hugo - winner')
    expect(publicLists).toHaveTextContent('1966: Nebula - nominee')
    expect(publicLists.textContent).toMatch(/1966: Hugo - winner.*1966: Nebula - nominee/u)
    expect(document.querySelector('.panel--book-details--collection')).not.toBeInTheDocument()
  })

  it('marks a collection so its details panel can share the page with included works', () => {
    renderWithProviders(<BookDetails />, {
      preloadedState: {
        ...baseState,
        storeBooks: {
          ...baseState.storeBooks,
          bookDetailsCurrent: { ...bookDetails, format: 'collection' },
          booksIndex: { 5: { ...bookIndexEntry, format: 'collection' } },
        },
      },
      urlStore: { routes },
    })

    expect(document.querySelector('.panel--book-details--collection')).toBeInTheDocument()
    expect(screen.getByTestId('book-cover')).toHaveAttribute('data-scroll-into-view', 'no')
    expect(screen.getByTestId('book-cover')).toHaveAttribute('data-size', 'lg')
  })

  it('shows another book in a compact panel and clears it from the header', async() => {
    const user = userEvent.setup()
    const onClose = vi.fn()
    const included = {
      ...bookDetails,
      id: 8,
      title: 'Hell',
      yearPublished: 2016,
    }

    renderWithProviders(
      <BookDetails
        bookId={8}
        header='Selected included work'
        onClose={onClose}
        reducedHeight
        showCover={false}
      />,
      {
        preloadedState: {
          ...baseState,
          storeBooks: {
            ...baseState.storeBooks,
            bookDetailsById: { 8: included },
            booksIndex: {
              ...baseState.storeBooks.booksIndex,
              8: { ...bookIndexEntry, id: 8, title: 'Hell', year: 2016 },
            },
          },
        },
        urlStore: { routes },
      }
    )

    expect(screen.getByRole('heading', { name: 'Hell' })).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Dune' })).not.toBeInTheDocument()
    expect(screen.queryByTestId('book-cover')).not.toBeInTheDocument()
    expect(document.querySelector('.book-details-panel--compact')).toBeInTheDocument()
    expect(fetchBookDetails).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Clear selected included work' }))
    expect(onClose).toHaveBeenCalledTimes(1)
  })

  it('keeps the previous details visible until the next book loads', () => {
    const { store } = renderWithProviders(<BookDetails />, {
      preloadedState: baseState,
      urlStore: { routes },
    })

    act(() => {
      store.dispatch(setCurrentBookId(6))
      store.dispatch(addBooks([{
        ...bookIndexEntry,
        id: 6,
        title: 'Messiah',
        year: 1969,
      }]))
    })

    expect(screen.getByRole('heading', { name: 'Dune' })).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Messiah' })).not.toBeInTheDocument()
    expect(fetchCurrentBookDetails).toHaveBeenCalled()
  })

  it('scrolls the details panel to the top when the book changes', () => {
    const nextBook = {
      ...bookIndexEntry,
      id: 6,
      title: 'Messiah',
      year: 1969,
    }
    const nextDetails = {
      ...bookDetails,
      id: 6,
      title: 'Messiah',
      yearPublished: 1969,
      summary: 'A sequel long enough to overflow the panel.',
    }
    const { store } = renderWithProviders(<BookDetails />, {
      preloadedState: baseState,
      urlStore: { routes },
    })
    const body = document.querySelector('.panel--book-details .panel--body')
    body.scrollTop = 140
    expect(body.scrollTop).toBe(140)

    act(() => {
      store.dispatch(setCurrentBookId(6))
      store.dispatch(addBooks([nextBook]))
      store.dispatch(setCurrentBookDetails(nextDetails))
    })

    expect(screen.getByRole('heading', { name: 'Messiah' })).toBeInTheDocument()
    expect(document.querySelector('.panel--book-details .panel--body').scrollTop).toBe(0)
  })

  it('leaves the details panel scroll when the book changes in the compact layout', () => {
    window.matchMedia = vi.fn().mockImplementation(query => ({
      addEventListener: vi.fn(),
      addListener: vi.fn(),
      matches: query === '(max-width: 899px)',
      media: query,
      removeEventListener: vi.fn(),
      removeListener: vi.fn(),
    }))

    const nextBook = {
      ...bookIndexEntry,
      id: 6,
      title: 'Messiah',
      year: 1969,
    }
    const nextDetails = {
      ...bookDetails,
      id: 6,
      title: 'Messiah',
      yearPublished: 1969,
      summary: 'A sequel long enough to overflow the panel.',
    }
    const { store } = renderWithProviders(
      <MemoryRouter initialEntries={['/authors/64']}>
        <BookDetails />
      </MemoryRouter>,
      {
        preloadedState: baseState,
        urlStore: { routes },
      }
    )
    const body = document.querySelector('.panel--book-details .panel--body')
    body.scrollTop = 140
    expect(body.scrollTop).toBe(140)

    act(() => {
      store.dispatch(setCurrentBookId(6))
      store.dispatch(addBooks([nextBook]))
      store.dispatch(setCurrentBookDetails(nextDetails))
    })

    expect(screen.getByRole('heading', { name: 'Messiah' })).toBeInTheDocument()
    expect(document.querySelector('.panel--book-details .panel--body').scrollTop).toBe(140)
    expect(screen.getByTestId('book-cover')).toHaveAttribute('data-size', 'xs')
    expect(document.querySelector('.book-details-panel-main-info .book-details-panel-annotation')).not.toBeInTheDocument()

    const cover = document.querySelector('.book-details-panel-cover')
    const annotation = document.querySelector('.book-details-panel-annotation')
    const supplement = document.querySelector('.book-details-panel-supplement')
    expect(cover.compareDocumentPosition(annotation) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy()
    expect(annotation.compareDocumentPosition(supplement) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy()
  })

  it('scrolls the included-work panel to the top when that work changes', () => {
    const included = (id, title) => ({
      details: { ...bookDetails, id, title, summary: `${title} summary` },
      index: { ...bookIndexEntry, id, title },
    })
    const first = included(8, 'Hell')
    const second = included(9, 'Heaven')
    const { rerender } = renderWithProviders(<BookDetails bookId={8} />, {
      urlStore: { routes },
      preloadedState: {
        ...baseState,
        storeBooks: {
          ...baseState.storeBooks,
          bookDetailsById: { 8: first.details, 9: second.details },
          booksIndex: {
            ...baseState.storeBooks.booksIndex,
            8: first.index,
            9: second.index,
          },
        },
      },
    })
    document.querySelector('.panel--book-details .panel--body').scrollTop = 90

    rerender(<BookDetails bookId={9} />)

    expect(screen.getByRole('heading', { name: 'Heaven' })).toBeInTheDocument()
    expect(document.querySelector('.panel--book-details .panel--body').scrollTop).toBe(0)
  })

  it('loads details for the requested book', () => {
    renderWithProviders(<BookDetails bookId={8} />, {
      preloadedState: {
        ...baseState,
        storeBooks: {
          ...baseState.storeBooks,
          booksIndex: {
            ...baseState.storeBooks.booksIndex,
            8: { ...bookIndexEntry, id: 8, title: 'Hell' },
          },
        },
      },
    })

    expect(fetchBookDetails).toHaveBeenCalledWith(8)
  })
})
