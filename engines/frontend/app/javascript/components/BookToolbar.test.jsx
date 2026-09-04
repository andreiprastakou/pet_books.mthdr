import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import BookToolbar from 'components/BookToolbar'
import { renderWithProviders } from 'test/renderWithProviders'

describe('BookToolbar', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderWithProviders(
      <BookToolbar bookPageHref='/books/1' />,
      { urlStore: { routesReady: false } }
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('copies the book page link and shows a success notification', async() => {
    const user = userEvent.setup()
    const writeText = vi.fn()
    vi.stubGlobal('navigator', { clipboard: { writeText } })

    const { store } = renderWithProviders(
      <BookToolbar bookPageHref='/books/42' />
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

  it('shows a not-implemented notice for bookmark', async() => {
    const user = userEvent.setup()

    const { store } = renderWithProviders(
      <BookToolbar bookPageHref='/books/1' />
    )

    await user.click(screen.getByTitle('Bookmark'))

    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'success',
        message: 'Dev note: not implemented!',
      }),
    ])
  })
})
