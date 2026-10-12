import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import Toolbar from 'panels/authorCard/Toolbar'
import apiClient from 'store/authors/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/authors/apiClient', () => ({
  default: {
    setAuthorPin: vi.fn(),
  },
}))

const authorFull = {
  id: 4,
  fullname: 'Ada Lovelace',
  booksCount: 2,
  pinned: false,
  externalLinks: [],
}

describe('author Toolbar', () => {
  afterEach(() => {
    apiClient.setAuthorPin.mockReset()
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderWithProviders(
      <Toolbar authorFull={authorFull} />,
      { urlStore: { routesReady: false } }
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('pins the author and keeps that state in the store', async() => {
    const user = userEvent.setup()
    // eslint-disable-next-line camelcase -- API payload key
    apiClient.setAuthorPin.mockResolvedValue({ author_id: 4, pinned: true })

    const { store } = renderWithProviders(
      <Toolbar authorFull={authorFull} />,
      {
        preloadedState: {
          storeAuthors: {
            authorsFull: { 4: { ...authorFull } },
            authorsIndex: {},
            authorsRefs: {},
            defaultPhotoUrl: null,
            refsLoaded: false,
          },
        },
      }
    )

    await user.click(screen.getByRole('button', { name: 'Pin' }))

    expect(apiClient.setAuthorPin).toHaveBeenCalledWith(4, true)
    expect(await screen.findByRole('button', { name: 'Unpin', pressed: true })).toBeInTheDocument()
    expect(store.getState().storeAuthors.authorsFull[4].pinned).toBe(true)
  })
})
