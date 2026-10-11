import React from 'react'
import { act, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import AuthorCardWrap from 'panels/authorCard/AuthorCard'
import { setCurrentAuthorId } from 'store/axis/actions'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('panels/authorCard/Toolbar', () => ({
  default: () => <div data-testid='author-toolbar' />,
}))

vi.mock('store/authors/actions', async() => {
  const actual = await vi.importActual('store/authors/actions')
  return {
    ...actual,
    fetchAuthorFull: vi.fn(() => () => undefined),
  }
})

const authorFull = {
  id: 7,
  fullname: 'Ada Lovelace',
  birthYear: 1815,
  deathYear: 1852,
  thumbUrl: '/authors/7.jpg',
  imageUrl: '/authors/7-full.jpg',
  tagIds: [11],
  booksCount: 2,
  externalLinks: [],
}

const baseState = {
  axis: {
    currentAuthorId: 7,
    currentBookId: null,
    currentTagId: null,
    seed: null,
  },
  storeAuthors: {
    authorsFull: { 7: authorFull },
    authorsIndex: {},
    authorsRefs: {},
    defaultPhotoUrl: '/default.jpg',
    refsLoaded: true,
  },
  storeTags: {
    categories: {},
    refsLoaded: true,
    tagsCategoriesIndex: {},
    tagsIndex: {},
    tagsRefs: { 11: { id: 11, name: 'math', connectionsCount: 2 } },
  },
}

describe('AuthorCard', () => {
  it('renders nothing when the author is not loaded', () => {
    const { container } = renderWithProviders(<AuthorCardWrap />, {
      preloadedState: {
        ...baseState,
        storeAuthors: { ...baseState.storeAuthors, authorsFull: {} },
      },
    })

    expect(container).toBeEmptyDOMElement()
  })

  it('renders lifetime, tags, and hides the picture when requested', () => {
    renderWithProviders(
      <AuthorCardWrap showPicture={false} />,
      { preloadedState: baseState }
    )

    expect(screen.getAllByText('Ada Lovelace').length).toBeGreaterThan(0)
    expect(screen.getByText(/1815-1852 \(age: 37\)/u)).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '#math' })).toBeInTheDocument()
    expect(document.querySelector('.author-image')).not.toBeInTheDocument()
    expect(document.querySelector('.author-card-without-picture')).toBeInTheDocument()
    expect(document.querySelector('.author-card-description')).not.toBeInTheDocument()
  })

  it('renders the description across the appended part of the card', () => {
    const withDescription = {
      ...authorFull,
      description: 'First bio.\nSecond line.',
      descriptionSource: 'Wikipedia',
    }

    renderWithProviders(
      <AuthorCardWrap showDescription />,
      {
        preloadedState: {
          ...baseState,
          storeAuthors: {
            ...baseState.storeAuthors,
            authorsFull: { 7: withDescription },
          },
        },
      }
    )

    expect(document.querySelector('.author-card--with-description')).toBeInTheDocument()
    expect(document.querySelector('.author-card-description')).toHaveTextContent('First bio.')
    expect(screen.getByText('(source: Wikipedia)')).toBeInTheDocument()
    expect(document.querySelector('.author-card-main .author-name')).toHaveTextContent('Ada Lovelace')
  })

  it('scrolls the author panel to the top when the author changes', () => {
    const nextAuthor = { ...authorFull, id: 8, fullname: 'Grace Hopper', birthYear: 1906, deathYear: 1992 }
    const { store } = renderWithProviders(<AuthorCardWrap />, {
      preloadedState: {
        ...baseState,
        storeAuthors: {
          ...baseState.storeAuthors,
          authorsFull: { 7: authorFull, 8: nextAuthor },
        },
      },
    })
    const body = document.querySelector('.panel--author-card .panel--body')
    body.scrollTop = 80
    expect(body.scrollTop).toBe(80)

    act(() => {
      store.dispatch(setCurrentAuthorId(8))
    })

    expect(screen.getAllByText('Grace Hopper').length).toBeGreaterThan(0)
    expect(document.querySelector('.panel--author-card .panel--body').scrollTop).toBe(0)
  })

  it('shows living age and opens the image modal on click', async() => {
    const user = userEvent.setup()
    const living = { ...authorFull, deathYear: null }
    const age = new Date().getFullYear() - 1815

    const { store } = renderWithProviders(<AuthorCardWrap />, {
      preloadedState: {
        ...baseState,
        storeAuthors: {
          ...baseState.storeAuthors,
          authorsFull: { 7: living },
        },
      },
    })

    expect(screen.getByText(new RegExp(`1815 \\(age: ${age}\\)`, 'u'))).toBeInTheDocument()

    await user.click(document.querySelector('.author-image'))
    expect(store.getState().imageModal.imageSrc).toBe('/authors/7-full.jpg')
  })
})
