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
    expect(document.querySelector('.b-cover-standard')).not.toHaveClass('b-standard-cover-small')
  })

  it('renders the small cover variant with year or label', () => {
    const { rerender } = renderWithProviders(
      <Book
        bookIndexEntry={{ ...bookIndexEntry, small: true }}
        label={null}
        scrollIntoView={false}
        showYear
      />,
      { preloadedState }
    )

    expect(document.querySelector('.b-standard-cover-small')).toBeInTheDocument()
    expect(screen.getByText('1965')).toBeInTheDocument()

    rerender(
      <Book
        bookIndexEntry={{ ...bookIndexEntry, small: true }}
        label='#1'
        scrollIntoView={false}
        showYear
      />
    )

    expect(screen.getByTitle('#1')).toHaveTextContent('#1')
    expect(screen.queryByText('1965')).not.toBeInTheDocument()
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
})
