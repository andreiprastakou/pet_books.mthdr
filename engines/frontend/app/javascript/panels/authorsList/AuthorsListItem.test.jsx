import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import AuthorsListItem from 'panels/authorsList/AuthorsListItem'
import { renderWithProviders } from 'test/renderWithProviders'

const author = {
  id: 7,
  fullname: 'Ada Lovelace',
  birthYear: 1815,
  rank: 3,
  thumbUrl: null,
}

const authorsPage = sortBy => ({
  authorIds: [],
  authorsTotal: 0,
  listFilter: {},
  page: 1,
  perPage: 40,
  sortBy,
})

describe('AuthorsListItem', () => {
  it('renders a placeholder when there is no thumb', () => {
    renderWithProviders(<AuthorsListItem author={author} />)

    expect(screen.getByTitle('Ada Lovelace')).toBeInTheDocument()
    expect(document.querySelector('.author-placeholder')).toBeInTheDocument()
    expect(screen.getByText('1815')).toBeInTheDocument()
  })

  it('shows birth year when sorted by years', () => {
    renderWithProviders(
      <AuthorsListItem author={{ ...author, thumbUrl: '/authors/7.jpg' }} />,
      { preloadedState: { authorsPage: authorsPage('years') } }
    )

    expect(document.querySelector('.author-placeholder')).not.toBeInTheDocument()
    expect(screen.getByText('1815')).toBeInTheDocument()
  })

  it('shows popularity rank and navigates on click', async() => {
    const user = userEvent.setup()
    const showAuthor = vi.fn()

    renderWithProviders(
      <AuthorsListItem author={{ ...author, thumbUrl: '/authors/7.jpg' }} />,
      {
        preloadedState: { authorsPage: authorsPage('popularity') },
        urlStore: { actions: { showAuthor } },
      }
    )

    expect(screen.getByText('#3')).toBeInTheDocument()
    await user.click(screen.getByTitle('Ada Lovelace'))
    expect(showAuthor).toHaveBeenCalledWith(7)
  })
})
