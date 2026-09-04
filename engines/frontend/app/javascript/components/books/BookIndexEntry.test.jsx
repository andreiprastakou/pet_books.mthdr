import React from 'react'
import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import BookIndexEntry from 'components/books/BookIndexEntry'
import { renderWithProviders } from 'test/renderWithProviders'
import { DEFAULT_COVER_SIZE } from 'utils/coverSizes'

describe('BookIndexEntry', () => {
  it('renders a placeholder when the book is missing from the store', () => {
    const { container } = renderWithProviders(
      <BookIndexEntry id={99} />
    )

    const placeholder = container.querySelector('.book-case.placeholder')
    expect(placeholder).toHaveClass(`b-cover-size-${DEFAULT_COVER_SIZE}`)
    expect(placeholder).toHaveAttribute('title', 'ID=99')
  })

  it('renders the book when an index entry exists', () => {
    renderWithProviders(
      <BookIndexEntry
        id={5}
        scrollIntoView={false}
      />,
      {
        preloadedState: {
          storeAuthors: {
            authorsFull: {},
            authorsIndex: {},
            authorsRefs: { 1: { id: 1, fullname: 'Frank Herbert' } },
            defaultPhotoUrl: null,
            refsLoaded: true,
          },
          storeBooks: {
            bookDetailsCurrent: {},
            booksIndex: {
              5: {
                id: 5,
                title: 'Dune',
                authorIds: [1],
                coverDesignId: 9,
                year: 1965,
              },
            },
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
        },
      }
    )

    expect(screen.getByTitle('Dune')).toBeInTheDocument()
    expect(screen.getByText('Dune')).toBeInTheDocument()
    expect(screen.getByText('Frank Herbert')).toBeInTheDocument()
  })
})
