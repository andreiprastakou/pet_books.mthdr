import React from 'react'
import { screen, within } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import UserPinsPage from 'pages/userPinsPage/Page'
import { renderWithProviders } from 'test/renderWithProviders'

const board = {
  authors: [{ id: 1, fullname: 'Ada Lovelace' }],
  books: [{ id: 2, title: 'Dune', year: 1965, authors: 'Frank Herbert' }],
  series: [{ id: 4, name: 'Earthsea' }],
}

describe('UserPinsPage', () => {
  it('shows the shared pin board without sharing controls', () => {
    renderWithProviders(<UserPinsPage status='ready' />, {
      preloadedState: { storePinBoard: board },
    })

    const pinBoard = screen.getByRole('region', { name: 'Pin board' })

    expect(within(pinBoard).queryByRole('button', { name: 'Copy shared pin board link' })).not.toBeInTheDocument()
    expect(within(pinBoard).queryByRole('button', { name: 'Unshare' })).not.toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Ada Lovelace' })).toHaveAttribute('href', '/authors/1')
    expect(screen.getByRole('link', { name: /Dune/u })).toHaveAttribute('href', '/books/2')
    expect(screen.getByRole('link', { name: 'Earthsea' })).toHaveAttribute('href', '/series/4')
  })

  it('explains when the sharing code is not valid', () => {
    renderWithProviders(<UserPinsPage status='missing' />)

    expect(screen.getByText('This shared pin board link is not valid.')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Copy shared pin board link' })).not.toBeInTheDocument()
  })
})
