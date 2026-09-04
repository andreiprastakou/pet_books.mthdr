import { configureStore } from '@reduxjs/toolkit'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import reducer from 'store/tags/slice'
import {
  fetchCategories,
  fetchTagsIndex,
  fetchTagsIndexEntry,
  fetchTagsRefs,
} from 'store/tags/actions'
import apiClient from 'store/tags/apiClient'

vi.mock('store/tags/apiClient', () => ({
  default: {
    getCategories: vi.fn(),
    getTagsIndex: vi.fn(),
    getTagsIndexEntry: vi.fn(),
    getTagsRefs: vi.fn(),
  },
}))

const makeStore = () => configureStore({
  reducer: { storeTags: reducer },
})

describe('tags actions', () => {
  beforeEach(() => {
    apiClient.getCategories.mockReset()
    apiClient.getTagsIndex.mockReset()
    apiClient.getTagsIndexEntry.mockReset()
    apiClient.getTagsRefs.mockReset()
  })

  it('fetches categories', async() => {
    const categories = [{ id: 1, name: 'Genre' }]
    apiClient.getCategories.mockResolvedValue(categories)

    const store = makeStore()
    await store.dispatch(fetchCategories())

    expect(store.getState().storeTags.categories).toEqual({ 1: categories[0] })
  })

  it('fetches tags index and groups by category', async() => {
    const entries = [
      { id: 1, name: 'fiction', categoryId: 10 },
      { id: 2, name: 'science', categoryId: 20 },
    ]
    apiClient.getTagsIndex.mockResolvedValue(entries)

    const store = makeStore()
    await store.dispatch(fetchTagsIndex())

    expect(store.getState().storeTags.tagsIndex).toEqual({
      1: entries[0],
      2: entries[1],
    })
    expect(store.getState().storeTags.tagsCategoriesIndex).toEqual({
      10: [entries[0]],
      20: [entries[1]],
    })
  })

  it('fetches a single tags index entry', async() => {
    const entry = { id: 5, name: 'noir', categoryId: 10 }
    apiClient.getTagsIndexEntry.mockResolvedValue(entry)

    const store = makeStore()
    await store.dispatch(fetchTagsIndexEntry(5))

    expect(apiClient.getTagsIndexEntry).toHaveBeenCalledWith(5)
    expect(store.getState().storeTags.tagsIndex).toEqual({ 5: entry })
  })

  it('fetches tags refs and marks them loaded', async() => {
    const refs = [{ id: 1, name: 'fiction', categoryId: 10 }]
    apiClient.getTagsRefs.mockResolvedValue(refs)

    const store = makeStore()
    await store.dispatch(fetchTagsRefs())

    expect(store.getState().storeTags.tagsRefs).toEqual({ 1: refs[0] })
    expect(store.getState().storeTags.refsLoaded).toBe(true)
  })
})
