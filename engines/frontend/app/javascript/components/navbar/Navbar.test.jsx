import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import PageNavbar from 'components/navbar/Navbar'
import publicListsApiClient from 'store/publicLists/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/publicLists/apiClient', () => ({
  default: {
    getTypes: vi.fn(),
  },
}))

describe('PageNavbar', () => {
  beforeEach(() => {
    publicListsApiClient.getTypes.mockReset()
    publicListsApiClient.getTypes.mockResolvedValue([])
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderWithProviders(<PageNavbar />, {
      urlStore: { routesReady: false },
    })

    expect(container).toBeEmptyDOMElement()
  })

  it('renders brand and section dropdowns when routes are ready', () => {
    renderWithProviders(<PageNavbar />)

    expect(screen.getByRole('link', { name: /Artspace \| Literature/u })).toHaveAttribute('href', '/books')
    expect(screen.getByText('Books')).toBeInTheDocument()
    expect(screen.getByText('Authors')).toBeInTheDocument()
    expect(screen.getByText('Tags')).toBeInTheDocument()
    expect(screen.getByText('Series')).toBeInTheDocument()
    expect(screen.getByText('Public lists')).toBeInTheDocument()
  })

  it('shows the signed-in email and a logout action', async() => {
    const user = userEvent.setup()

    renderWithProviders(<PageNavbar currentUserEmail='reader@example.com' />)

    await user.click(screen.getByRole('button', { name: 'Account' }))

    const email = screen.getByText('reader@example.com')
    const pinBoard = screen.getByRole('link', { name: 'Pin board' })
    const myRead = screen.getByRole('link', { name: 'Your reads' })
    const logout = screen.getByRole('button', { name: 'Log out' })

    expect(pinBoard).toHaveAttribute('href', '/pins')
    expect(myRead).toHaveAttribute('href', '/reads')
    expect(email.compareDocumentPosition(pinBoard)).toBe(Node.DOCUMENT_POSITION_FOLLOWING)
    expect(pinBoard.compareDocumentPosition(myRead)).toBe(Node.DOCUMENT_POSITION_FOLLOWING)
    expect(myRead.compareDocumentPosition(logout)).toBe(Node.DOCUMENT_POSITION_FOLLOWING)
    expect(logout.closest('form')).toHaveAttribute('action', '/logout')
  })

  it('triggers BOOKS_NAV_CLICKED when the Books dropdown is opened', async() => {
    const user = userEvent.setup()
    const triggerEvent = vi.fn()

    renderWithProviders(<PageNavbar />, {
      events: { triggerEvent },
    })

    await user.click(screen.getByText('Books'))
    expect(triggerEvent).toHaveBeenCalledWith('BOOKS_NAV_CLICKED')
  })
})
