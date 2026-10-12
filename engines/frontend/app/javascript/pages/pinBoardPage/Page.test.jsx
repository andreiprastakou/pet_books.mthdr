import React from 'react'
import { screen, within } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import PinBoardPage from 'pages/pinBoardPage/Page'
import apiClient from 'store/pinBoard/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/pinBoard/apiClient', () => ({
  default: {
    getPinBoard: vi.fn(),
  },
}))

const board = {
  authors: [{ id: 1, fullname: 'Ada Lovelace' }],
  books: [{ id: 2, title: 'Dune', year: 1965, authors: 'Frank Herbert' }],
  series: [
    { id: 4, name: 'Earthsea' },
    { id: 3, name: 'Dune' },
  ],
}

describe('PinBoardPage', () => {
  beforeEach(() => {
    apiClient.getPinBoard.mockReset()
    apiClient.getPinBoard.mockResolvedValue(board)
  })

  it('shows a title-only pin board and the three pinned lists', async() => {
    renderWithProviders(<PinBoardPage />)

    const pinBoard = await screen.findByRole('region', { name: 'Pin board' })
    const authors = screen.getByRole('region', { name: 'Authors' })
    const books = screen.getByRole('region', { name: 'Books' })
    const series = screen.getByRole('region', { name: 'Series' })

    expect(pinBoard.querySelector('.panel--body')).not.toBeInTheDocument()
    expect(within(authors).getByText('1')).toBeInTheDocument()
    expect(within(authors).getByRole('link', { name: 'Ada Lovelace' })).toHaveAttribute('href', '/authors/1')
    expect(within(authors).getByRole('link', { name: 'Ada Lovelace' })).toHaveAttribute('title', 'Ada Lovelace')

    const bookLink = within(books).getByRole('link', { name: /Dune/u })
    expect(bookLink).toHaveAttribute('href', '/books/2')
    expect(bookLink).toHaveAttribute('title', 'Dune (1965) Frank Herbert')
    expect(within(bookLink).getByText('1965')).toBeInTheDocument()
    expect(within(bookLink).getByText('Frank Herbert')).toBeInTheDocument()

    expect(within(series).getByText('2')).toBeInTheDocument()
    expect(within(series).getByRole('link', { name: 'Earthsea' })).toHaveAttribute('href', '/series/4')
    expect(within(series).getByRole('link', { name: 'Earthsea' })).toHaveAttribute('title', 'Earthsea')
  })
})
