import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import BookToolbar from 'components/BookToolbar'
import apiClient from 'store/books/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/books/apiClient', () => ({
  default: {
    setBookPin: vi.fn(),
    setBookRead: vi.fn(),
  },
}))

describe('BookToolbar', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
    apiClient.setBookPin.mockReset()
    apiClient.setBookRead.mockReset()
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderWithProviders(
      <BookToolbar
        bookId={1}
        bookPageHref='/books/1'
        pinned={false}
        read={false}
      />,
      { urlStore: { routesReady: false } }
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('copies the book page link and shows a success notification', async() => {
    const user = userEvent.setup()
    const writeText = vi.fn()
    vi.stubGlobal('navigator', { clipboard: { writeText } })

    const { store } = renderWithProviders(
      <BookToolbar
        bookId={42}
        bookPageHref='/books/42'
        pinned={false}
        read={false}
      />
    )

    await user.click(screen.getByTitle('Copy book page link'))

    expect(writeText).toHaveBeenCalledWith(`${window.location.origin}/books/42`)
    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'success',
        message: 'Link copied to clipboard!',
      }),
    ])
  })

  it('shows a thumbtack while offering to pin', async() => {
    const user = userEvent.setup()
    renderWithProviders(
      <BookToolbar
        bookId={1}
        bookPageHref='/books/1'
        pinned={false}
        read={false}
      />
    )
    const button = screen.getByRole('button', { name: 'Pin' })

    expect(button).toHaveAttribute('title', 'Pin')
    expect(button).toHaveAttribute('aria-pressed', 'false')
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'thumbtack')

    await user.hover(button)
    expect(button).toHaveAttribute('title', 'Pin')
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'thumbtack')
  })

  it('shows a circle, and previews a slashed thumbtack while offering to unpin', async() => {
    const user = userEvent.setup()
    renderWithProviders(
      <BookToolbar
        bookId={1}
        bookPageHref='/books/1'
        pinned
        read={false}
      />
    )
    const button = screen.getByRole('button', { name: 'Pin' })

    expect(button).toHaveAttribute('aria-pressed', 'true')
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'circle-dot')

    await user.hover(button)
    expect(button).toHaveAttribute('title', 'Unpin')
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'thumbtack-slash')
  })

  it('pins the book and keeps that state in the store', async() => {
    const user = userEvent.setup()
    apiClient.setBookPin.mockResolvedValue({ book_id: 7, pinned: true })

    const { store } = renderWithProviders(
      <BookToolbar
        bookId={7}
        bookPageHref='/books/7'
        pinned={false}
        read={false}
      />,
      {
        preloadedState: {
          storeBooks: {
            booksIndex: {},
            booksRefs: {},
            bookDetailsById: { 7: { id: 7, pinned: false, read: false } },
            bookDetailsCurrent: { id: 7, pinned: false, read: false },
            requestedBookId: null,
          },
        },
      }
    )

    await user.click(screen.getByRole('button', { name: 'Pin' }))

    expect(apiClient.setBookPin).toHaveBeenCalledWith(7, true)
    expect(await screen.findByRole('button', { name: 'Unpin', pressed: true })).toBeInTheDocument()
    expect(store.getState().storeBooks.bookDetailsCurrent.pinned).toBe(true)
    expect(store.getState().storeBooks.bookDetailsById[7].pinned).toBe(true)
  })

  it('unpins the book and reports a failure without keeping the new state', async() => {
    const user = userEvent.setup()
    apiClient.setBookPin.mockRejectedValue(new Error('nope'))

    const { store } = renderWithProviders(
      <BookToolbar
        bookId={7}
        bookPageHref='/books/7'
        pinned
        read={false}
      />
    )

    await user.hover(screen.getByRole('button', { name: 'Pin' }))
    await user.click(screen.getByRole('button', { name: 'Unpin' }))

    expect(apiClient.setBookPin).toHaveBeenCalledWith(7, false)
    expect(await screen.findByRole('button', { name: 'Unpin', pressed: true })).toBeInTheDocument()
    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'danger',
        message: 'Could not update pin. Please try again.',
      }),
    ])
  })

  it('shows an open book, and previews the held book while offering to mark it read', async() => {
    const user = userEvent.setup()
    renderWithProviders(
      <BookToolbar
        bookId={1}
        bookPageHref='/books/1'
        pinned={false}
        read={false}
      />
    )
    const button = screen.getByRole('button', { name: 'Mark as read' })

    expect(button).toHaveAttribute('title', 'Mark as read')
    expect(button).toHaveAttribute('aria-pressed', 'false')
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'book')

    await user.hover(button)
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'book-open-reader')
  })

  it('shows a held book, and previews the open book while offering to unmark it', async() => {
    const user = userEvent.setup()
    renderWithProviders(
      <BookToolbar
        bookId={1}
        bookPageHref='/books/1'
        pinned={false}
        read
      />
    )
    const button = screen.getByRole('button', { name: 'Mark as not read' })

    expect(button).toHaveAttribute('aria-pressed', 'true')
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'book-open-reader')

    await user.hover(button)
    expect(button.querySelector('svg')).toHaveAttribute('data-icon', 'book')
  })

  it('marks the book read and keeps that state in the store', async() => {
    const user = userEvent.setup()
    apiClient.setBookRead.mockResolvedValue({ book_id: 7, read: true })

    const { store } = renderWithProviders(
      <BookToolbar
        bookId={7}
        bookPageHref='/books/7'
        pinned={false}
        read={false}
      />,
      {
        preloadedState: {
          storeBooks: {
            booksIndex: {},
            booksRefs: {},
            bookDetailsById: { 7: { id: 7, read: false } },
            bookDetailsCurrent: { id: 7, read: false },
            requestedBookId: null,
          },
        },
      }
    )

    await user.click(screen.getByRole('button', { name: 'Mark as read' }))

    expect(apiClient.setBookRead).toHaveBeenCalledWith(7, true)
    expect(await screen.findByRole('button', { name: 'Mark as not read' })).toBeInTheDocument()
    expect(store.getState().storeBooks.bookDetailsCurrent.read).toBe(true)
    expect(store.getState().storeBooks.bookDetailsById[7].read).toBe(true)
  })

  it('unmarks the book and reports a failure without keeping the new state', async() => {
    const user = userEvent.setup()
    apiClient.setBookRead.mockRejectedValue(new Error('nope'))

    const { store } = renderWithProviders(
      <BookToolbar
        bookId={7}
        bookPageHref='/books/7'
        pinned={false}
        read
      />
    )

    await user.click(screen.getByRole('button', { name: 'Mark as not read' }))

    expect(apiClient.setBookRead).toHaveBeenCalledWith(7, false)
    expect(await screen.findByRole('button', { name: 'Mark as not read' })).toBeInTheDocument()
    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'danger',
        message: 'Could not update read status. Please try again.',
      }),
    ])
  })
})
