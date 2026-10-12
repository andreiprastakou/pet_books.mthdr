import React from 'react'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import SeriesIntro from 'panels/seriesIntro/SeriesIntro'
import apiClient from 'store/series/apiClient'
import { renderWithProviders } from 'test/renderWithProviders'

vi.mock('store/series/apiClient', () => ({
  default: {
    setSeriesPin: vi.fn(),
  },
}))

describe('SeriesIntro', () => {
  afterEach(() => {
    apiClient.setSeriesPin.mockReset()
  })

  it('renders nothing without a series', () => {
    const { container } = renderWithProviders(<SeriesIntro series={null} />)

    expect(container).toBeEmptyDOMElement()
  })

  it('shows the pin control even when the series has no links', () => {
    renderWithProviders(
      <SeriesIntro series={{ id: 3, name: 'Earthsea', pinned: false, externalLinks: [] }} />
    )

    expect(screen.getByText('Earthsea')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Pin' })).toBeInTheDocument()
    expect(document.querySelector('.panel--body')).toBeInTheDocument()
  })

  it('pins the series and keeps that state in the store', async() => {
    const user = userEvent.setup()
    // eslint-disable-next-line camelcase -- API payload key
    apiClient.setSeriesPin.mockResolvedValue({ series_id: 3, pinned: true })

    const { store } = renderWithProviders(
      <SeriesIntro series={{ id: 3, name: 'Earthsea', pinned: false, externalLinks: [] }} />,
      {
        preloadedState: {
          storeSeries: {
            seriesIndex: { 3: { id: 3, name: 'Earthsea', pinned: false } },
            seriesRefs: {},
            refsLoaded: false,
          },
        },
      }
    )

    await user.click(screen.getByRole('button', { name: 'Pin' }))

    expect(apiClient.setSeriesPin).toHaveBeenCalledWith(3, true)
    expect(await screen.findByRole('button', { name: 'Unpin', pressed: true })).toBeInTheDocument()
    expect(store.getState().storeSeries.seriesIndex[3].pinned).toBe(true)
  })
})
