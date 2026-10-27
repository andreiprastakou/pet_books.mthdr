import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { MemoryRouter } from 'react-router-dom'

import PageNavbar from 'components/navbar/Navbar'
import publicListsApiClient from 'store/publicLists/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/publicLists/apiClient', () => ({
  default: {
    getTypes: vi.fn(),
  },
}))

const stubNarrowViewport = () => {
  window.matchMedia = vi.fn().mockImplementation(query => ({
    addEventListener: vi.fn(),
    addListener: vi.fn(),
    matches: query === '(max-width: 899px)',
    media: query,
    removeEventListener: vi.fn(),
    removeListener: vi.fn(),
  }))
}

const renderNavbar = (ui, options = {}) => {
  const { route = '/books', ...rest } = options

  return renderWithProviders(
    <MemoryRouter initialEntries={[route]}>
      { ui }
    </MemoryRouter>,
    rest
  )
}

describe('PageNavbar', () => {
  const { matchMedia } = window

  beforeEach(() => {
    publicListsApiClient.getTypes.mockReset()
    publicListsApiClient.getTypes.mockResolvedValue([])
    window.matchMedia = matchMedia
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderNavbar(<PageNavbar />, {
      urlStore: { routesReady: false },
    })

    expect(container).toBeEmptyDOMElement()
  })

  it('renders brand and section dropdowns when routes are ready', () => {
    renderNavbar(<PageNavbar />)

    expect(screen.getByRole('link', { name: /Artspace \| Literature/u })).toHaveAttribute('href', '/books')
    expect(screen.getByText('Books')).toBeInTheDocument()
    expect(screen.getByText('Authors')).toBeInTheDocument()
    expect(screen.getByText('Tags')).toBeInTheDocument()
    expect(screen.getByText('Series')).toBeInTheDocument()
    expect(screen.getByText('Public lists')).toBeInTheDocument()
  })

  it('shows the signed-in email and a logout action', async() => {
    const user = userEvent.setup()

    renderNavbar(<PageNavbar currentUserEmail='reader@example.com' />)

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

    renderNavbar(<PageNavbar />, {
      events: { triggerEvent },
    })

    await user.click(screen.getByText('Books'))
    expect(triggerEvent).toHaveBeenCalledWith('BOOKS_NAV_CLICKED')
  })

  it('opens a compact drawer of collapsed sections on a narrow author page', async() => {
    const user = userEvent.setup()
    const triggerEvent = vi.fn()

    stubNarrowViewport()

    renderNavbar(<PageNavbar currentUserEmail='reader@example.com' />, {
      events: { triggerEvent },
      route: '/authors/64',
    })

    const burger = screen.getByRole('button', { name: 'Open menu' })

    expect(burger).toHaveAttribute('aria-expanded', 'false')
    expect(burger).toHaveAttribute('aria-controls', 'page-nav-drawer')
    expect(screen.queryByRole('link', { name: 'List all' })).not.toBeInTheDocument()
    expect(screen.queryByText('reader@example.com')).not.toBeInTheDocument()

    await user.click(burger)

    expect(burger).toHaveAttribute('aria-expanded', 'true')
    expect(screen.getByRole('button', { name: 'Books' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Authors' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Tags' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Series' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Public lists' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Account' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'List all' })).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Books' }))

    expect(triggerEvent).toHaveBeenCalledWith('BOOKS_NAV_CLICKED')
    expect(screen.getByRole('link', { name: 'List all' })).toHaveAttribute('href', '/books')
  })

  it('uses the compact menu on a narrow reads page', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/reads' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow pin board', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/pins' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow books index', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/books' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow public lists page', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/public-lists/7' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow series page', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/series/11' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow series index', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/series' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow tag page', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/tags/11' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow tags index', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/tags' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })

  it('uses the compact menu on a narrow authors index', () => {
    stubNarrowViewport()

    renderNavbar(<PageNavbar />, { route: '/authors' })

    expect(screen.getByRole('button', { name: 'Open menu' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Books' })).not.toBeInTheDocument()
  })
})
