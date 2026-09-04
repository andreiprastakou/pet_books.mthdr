import { configureStore } from '@reduxjs/toolkit'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import reducer from 'store/coverDesigns/slice'
import { fetchCoverDesigns } from 'store/coverDesigns/actions'
import apiClient from 'store/coverDesigns/apiClient'

vi.mock('store/coverDesigns/apiClient', () => ({
  default: {
    getCoverDesigns: vi.fn(),
  },
}))

const makeStore = preloadedState => configureStore({
  reducer: { storeCoverDesigns: reducer },
  preloadedState: preloadedState
    ? { storeCoverDesigns: preloadedState }
    : undefined,
})

describe('fetchCoverDesigns', () => {
  beforeEach(() => {
    apiClient.getCoverDesigns.mockReset()
  })

  it('fetches cover designs once and stores them by id', async() => {
    const coverDesigns = [
      { id: 1, name: 'Classic' },
      { id: 2, name: 'Modern' },
    ]
    apiClient.getCoverDesigns.mockResolvedValue(coverDesigns)

    const store = makeStore()
    await store.dispatch(fetchCoverDesigns())

    expect(apiClient.getCoverDesigns).toHaveBeenCalledTimes(1)
    expect(store.getState().storeCoverDesigns).toEqual({
      coverDesigns: {
        1: coverDesigns[0],
        2: coverDesigns[1],
      },
      coverDesignsLoaded: true,
    })
  })

  it('skips the API when cover designs are already loaded', async() => {
    const store = makeStore({
      coverDesigns: { 1: { id: 1, name: 'Classic' } },
      coverDesignsLoaded: true,
    })

    await store.dispatch(fetchCoverDesigns())

    expect(apiClient.getCoverDesigns).not.toHaveBeenCalled()
    expect(store.getState().storeCoverDesigns.coverDesignsLoaded).toBe(true)
  })
})
