import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import SearchForm from 'components/navbar/SearchForm'
import { renderWithProviders } from 'test/renderWithProviders'

const deferred = () => {
  let resolve
  let reject
  const promise = {
    then(onFulfilled) {
      resolve = onFulfilled
      return {
        fail(onRejected) {
          reject = onRejected
          return this
        },
      }
    },
    fail(onRejected) {
      reject = onRejected
      return this
    },
    _resolve(value) { resolve?.(value) },
    _reject(error) { reject?.(error) },
  }
  return promise
}

describe('SearchForm', () => {
  it('does not search when the query is empty', async() => {
    const user = userEvent.setup()
    const apiSearcher = vi.fn(() => deferred())

    const { container } = renderWithProviders(
      <SearchForm apiSearcher={apiSearcher} />
    )

    await user.click(container.querySelector('form'))
    container.querySelector('form').dispatchEvent(
      new Event('submit', { bubbles: true, cancelable: true })
    )

    expect(apiSearcher).not.toHaveBeenCalled()
  })

  it('shows a spinner while searching and clears it on success', async() => {
    const user = userEvent.setup()
    const request = deferred()
    const apiSearcher = vi.fn(() => request)

    renderWithProviders(<SearchForm apiSearcher={apiSearcher} />)

    await user.type(screen.getByRole('textbox'), 'dune')
    await user.keyboard('{Enter}')

    expect(apiSearcher).toHaveBeenCalledWith('dune')
    expect(document.querySelector('.search-spinner')).toBeInTheDocument()

    request._resolve()
    await waitFor(() => {
      expect(document.querySelector('.search-spinner')).not.toBeInTheDocument()
    })
  })

  it('dispatches an error notification when search fails', async() => {
    const user = userEvent.setup()
    const request = deferred()
    const apiSearcher = vi.fn(() => request)

    const { store } = renderWithProviders(<SearchForm apiSearcher={apiSearcher} />)

    await user.type(screen.getByRole('textbox'), 'dune')
    await user.keyboard('{Enter}')
    request._reject()

    await waitFor(() => {
      expect(store.getState().notifications.messages).toEqual([
        expect.objectContaining({
          type: 'danger',
          message: 'Search failed!',
        }),
      ])
    })
  })

  it('subscribes to the focus event', () => {
    const subscribeToEvent = vi.fn(() => vi.fn())

    renderWithProviders(
      <SearchForm
        apiSearcher={vi.fn()}
        focusEvent='BOOKS_NAV_CLICKED'
      />,
      { events: { subscribeToEvent } }
    )

    expect(subscribeToEvent).toHaveBeenCalledWith('BOOKS_NAV_CLICKED', expect.any(Function))
  })
})
