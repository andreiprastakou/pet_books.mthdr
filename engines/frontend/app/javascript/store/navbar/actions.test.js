import { configureStore } from '@reduxjs/toolkit'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import authorsReducer from 'store/authors/slice'
import tagsReducer from 'store/tags/slice'
import { prepareNavRefs } from 'store/navbar/actions'
import authorsApiClient from 'store/authors/apiClient'
import tagsApiClient from 'store/tags/apiClient'

vi.mock('store/authors/apiClient', () => ({
  default: {
    getAuthorsRefs: vi.fn(),
  },
}))

vi.mock('store/tags/apiClient', () => ({
  default: {
    getTagsRefs: vi.fn(),
  },
}))

const makeStore = preloadedState => configureStore({
  reducer: {
    storeAuthors: authorsReducer,
    storeTags: tagsReducer,
  },
  preloadedState,
})

describe('prepareNavRefs', () => {
  beforeEach(() => {
    authorsApiClient.getAuthorsRefs.mockReset()
    tagsApiClient.getTagsRefs.mockReset()
  })

  it('fetches missing authors and tags refs', async() => {
    authorsApiClient.getAuthorsRefs.mockResolvedValue([{ id: 1, fullname: 'Ada' }])
    tagsApiClient.getTagsRefs.mockResolvedValue([{ id: 2, name: 'fiction', categoryId: 1 }])

    const store = makeStore()
    await store.dispatch(prepareNavRefs())

    expect(authorsApiClient.getAuthorsRefs).toHaveBeenCalledTimes(1)
    expect(tagsApiClient.getTagsRefs).toHaveBeenCalledTimes(1)
    expect(store.getState().storeAuthors.refsLoaded).toBe(true)
    expect(store.getState().storeTags.refsLoaded).toBe(true)
  })

  it('skips fetches when refs are already loaded', async() => {
    const store = makeStore({
      storeAuthors: {
        authorsFull: {},
        authorsIndex: {},
        authorsRefs: { 1: { id: 1, fullname: 'Ada' } },
        defaultPhotoUrl: null,
        refsLoaded: true,
      },
      storeTags: {
        categories: {},
        tagsIndex: {},
        tagsCategoriesIndex: {},
        tagsRefs: { 2: { id: 2, name: 'fiction', categoryId: 1 } },
        refsLoaded: true,
      },
    })

    await store.dispatch(prepareNavRefs())

    expect(authorsApiClient.getAuthorsRefs).not.toHaveBeenCalled()
    expect(tagsApiClient.getTagsRefs).not.toHaveBeenCalled()
  })
})
