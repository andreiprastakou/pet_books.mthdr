import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import ShareReadsButton from 'pages/readsPage/ShareReadsButton'
import apiClient from 'store/userReadsSharings/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/userReadsSharings/apiClient', () => ({
  default: {
    create: vi.fn(),
    current: vi.fn(),
    destroy: vi.fn(),
  },
}))

describe('ShareReadsButton', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
    apiClient.create.mockReset()
    apiClient.current.mockReset()
    apiClient.destroy.mockReset()
    apiClient.current.mockRejectedValue({ status: 404 })
  })

  it('renders nothing when routes are not ready', () => {
    const { container } = renderWithProviders(<ShareReadsButton />, {
      urlStore: { routesReady: false },
    })

    expect(container).toBeEmptyDOMElement()
  })

  it('shows Unshare when reads are already shared', async() => {
    apiClient.current.mockResolvedValue({ code: 'a'.repeat(16) })

    renderWithProviders(<ShareReadsButton />)

    expect(await screen.findByRole('button', { name: 'Unshare' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Copy shared reads link' })).toBeInTheDocument()
  })

  it('registers a sharing code and copies the shared reads link', async() => {
    const user = userEvent.setup()
    const writeText = vi.fn().mockResolvedValue()
    vi.stubGlobal('navigator', { clipboard: { writeText } })
    apiClient.create.mockResolvedValue({ code: 'a'.repeat(16) })

    const { store } = renderWithProviders(<ShareReadsButton />)

    await user.click(screen.getByRole('button', { name: 'Copy shared reads link' }))

    expect(apiClient.create).toHaveBeenCalledOnce()
    expect(writeText).toHaveBeenCalledWith(`${window.location.origin}/reads/${'a'.repeat(16)}`)
    expect(await screen.findByRole('button', { name: 'Unshare' })).toBeInTheDocument()
    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'success',
        message: 'Link copied to clipboard!',
      }),
    ])
  })

  it('removes the sharing code', async() => {
    const user = userEvent.setup()
    apiClient.current.mockResolvedValue({ code: 'a'.repeat(16) })
    apiClient.destroy.mockResolvedValue()

    const { store } = renderWithProviders(<ShareReadsButton />)

    await user.click(await screen.findByRole('button', { name: 'Unshare' }))

    expect(apiClient.destroy).toHaveBeenCalledOnce()
    expect(screen.queryByRole('button', { name: 'Unshare' })).not.toBeInTheDocument()
    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'success',
        message: 'Your reads are no longer shared.',
      }),
    ])
  })

  it('reports an error when the sharing code cannot be created', async() => {
    const user = userEvent.setup()
    const writeText = vi.fn()
    vi.stubGlobal('navigator', { clipboard: { writeText } })
    apiClient.create.mockRejectedValue({ status: 500 })

    const { store } = renderWithProviders(<ShareReadsButton />)

    await user.click(screen.getByRole('button', { name: 'Copy shared reads link' }))

    expect(writeText).not.toHaveBeenCalled()
    expect(screen.queryByRole('button', { name: 'Unshare' })).not.toBeInTheDocument()
    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'danger',
        message: 'Could not copy the shared reads link. Please try again.',
      }),
    ])
  })

  it('reports an error when unsharing fails', async() => {
    const user = userEvent.setup()
    apiClient.current.mockResolvedValue({ code: 'a'.repeat(16) })
    apiClient.destroy.mockRejectedValue({ status: 500 })

    const { store } = renderWithProviders(<ShareReadsButton />)

    await user.click(await screen.findByRole('button', { name: 'Unshare' }))

    expect(screen.getByRole('button', { name: 'Unshare' })).toBeInTheDocument()
    expect(store.getState().notifications.messages).toEqual([
      expect.objectContaining({
        type: 'danger',
        message: 'Could not unshare your reads. Please try again.',
      }),
    ])
  })
})
