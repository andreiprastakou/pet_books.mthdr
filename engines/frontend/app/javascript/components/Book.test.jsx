import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import Book from 'components/Book'
import { renderWithProviders } from 'test/renderWithProviders'

const coverDesign = {
  id: 9,
  coverImage: 'default',
  titleFont: 'serif',
  titleColor: 'dark',
  authorNameFont: 'serif',
  authorNameColor: 'dark',
}

const bookIndexEntry = {
  id: 5,
  title: 'Dune',
  authorIds: [1],
  coverDesignId: 9,
  year: 1965,
  format: 'normal',
}

const preloadedState = {
  axis: {
    currentAuthorId: null,
    currentBookId: null,
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
  storeCoverDesigns: {
    coverDesigns: { 9: coverDesign },
    coverDesignsLoaded: true,
  },
}

describe('Book', () => {
  it('renders a standard cover with authors', () => {
    renderWithProviders(
      <Book
        bookIndexEntry={bookIndexEntry}
        scrollIntoView={false}
      />,
      { preloadedState }
    )

    expect(screen.getByTitle('Dune')).toBeInTheDocument()
    expect(screen.getByText('Dune')).toBeInTheDocument()
    expect(screen.getByText('Frank Herbert')).toBeInTheDocument()
    expect(document.querySelector('.b-cover-standard')).not.toHaveClass('b-standard-cover--small')
    expect(document.querySelector('.b-cover-standard')).toHaveClass('b-standard-cover--normal')
  })

  it('renders the small cover variant with year or label', () => {
    const { rerender } = renderWithProviders(
      <Book
        bookIndexEntry={{ ...bookIndexEntry, format: 'small' }}
        label={null}
        scrollIntoView={false}
        showYear
      />,
      { preloadedState }
    )

    expect(document.querySelector('.b-standard-cover--small')).toBeInTheDocument()
    expect(screen.getByText('1965')).toBeInTheDocument()

    rerender(
      <Book
        bookIndexEntry={{ ...bookIndexEntry, format: 'small' }}
        label='#1'
        scrollIntoView={false}
        showYear
      />
    )

    expect(screen.getByTitle('#1')).toHaveTextContent('#1')
    expect(screen.queryByText('1965')).not.toBeInTheDocument()
  })

  it('renders a collection cover on the near-white palette at novel size', () => {
    renderWithProviders(
      <Book
        bookIndexEntry={{ ...bookIndexEntry, format: 'collection' }}
        scrollIntoView={false}
      />,
      {
        preloadedState: {
          ...preloadedState,
          storeCoverDesigns: {
            coverDesigns: {
              9: { ...coverDesign, coverImage: 'parchment', titleColor: 'white' },
            },
            coverDesignsLoaded: true,
          },
        },
      }
    )

    const cover = document.querySelector('.b-cover-standard')
    expect(cover).toHaveClass('b-standard-cover--collection')
    expect(cover).not.toHaveClass('b-standard-cover--small')
    expect(cover).toHaveAttribute('data-cover-image', 'default')
    expect(cover.style.background).toContain('#e9f1f0')
  })

  it('marks the current book and navigates on click', async() => {
    const user = userEvent.setup()
    const showBooksIndexEntry = vi.fn()

    renderWithProviders(
      <Book
        bookIndexEntry={bookIndexEntry}
        scrollIntoView={false}
      />,
      {
        preloadedState: {
          ...preloadedState,
          axis: { ...preloadedState.axis, currentBookId: 5 },
        },
        urlStore: { actions: { showBooksIndexEntry } },
      }
    )

    const cover = screen.getByTitle('Dune')
    expect(cover).toHaveClass('selected')

    await user.click(cover)
    expect(showBooksIndexEntry).toHaveBeenCalledWith(5)
  })

  it('uses a custom selection instead of the current book', async() => {
    const user = userEvent.setup()
    const onSelect = vi.fn()
    const showBooksIndexEntry = vi.fn()

    renderWithProviders(
      <Book
        bookIndexEntry={bookIndexEntry}
        onSelect={onSelect}
        scrollIntoView={false}
        selectedId={4}
      />,
      {
        preloadedState: {
          ...preloadedState,
          axis: { ...preloadedState.axis, currentBookId: 5 },
        },
        urlStore: { actions: { showBooksIndexEntry } },
      }
    )

    const cover = screen.getByTitle('Dune')
    expect(cover).not.toHaveClass('selected')

    await user.click(cover)
    expect(onSelect).toHaveBeenCalledWith(5)
    expect(showBooksIndexEntry).not.toHaveBeenCalled()
  })
})
