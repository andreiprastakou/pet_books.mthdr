import React from 'react'
import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import BookSpine from 'panels/booksStack/BookSpine'
import { renderWithProviders } from 'test/renderWithProviders'

const renderSpine = book => renderWithProviders(<BookSpine id={book.id} />, {
  preloadedState: {
    axis: { currentBookId: null },
    storeBooks: {
      booksIndex: { [book.id]: book },
    },
  },
})

describe('BookSpine', () => {
  it('marks a read spine with a bookmark', () => {
    renderSpine({ id: 1, title: 'Dune', year: 1965, read: true })

    expect(screen.getByRole('img', { name: 'Read' })).toHaveClass('book-read-mark')
  })

  it('leaves an unread spine unmarked', () => {
    renderSpine({ id: 1, title: 'Dune', year: 1965, read: false })

    expect(screen.queryByRole('img', { name: 'Read' })).not.toBeInTheDocument()
  })
})
