import { configureStore } from '@reduxjs/toolkit'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import reducer from 'store/authors/slice'
import {
  fetchAuthorFull,
  fetchAuthorsIndex,
  fetchAuthorsRefs,
} from 'store/authors/actions'
import apiClient from 'store/authors/apiClient'

vi.mock('store/authors/apiClient', () => ({
  default: {
    getAuthorsRefs: vi.fn(),
    getAuthorsIndex: vi.fn(),
    getAuthorFull: vi.fn(),
  },
}))

const makeStore = () => configureStore({
  reducer: { storeAuthors: reducer },
})

describe('authors actions', () => {
  beforeEach(() => {
    apiClient.getAuthorsRefs.mockReset()
    apiClient.getAuthorsIndex.mockReset()
    apiClient.getAuthorFull.mockReset()
  })

  it('fetches author refs into the store', async() => {
    const refs = [{ id: 1, fullname: 'Ada' }]
    apiClient.getAuthorsRefs.mockResolvedValue(refs)

    const store = makeStore()
    await store.dispatch(fetchAuthorsRefs())

    expect(apiClient.getAuthorsRefs).toHaveBeenCalledTimes(1)
    expect(store.getState().storeAuthors.authorsRefs).toEqual({ 1: refs[0] })
    expect(store.getState().storeAuthors.refsLoaded).toBe(true)
  })

  it('fetches authors index into the store', async() => {
    const list = [{ id: 2, fullname: 'Bob' }]
    apiClient.getAuthorsIndex.mockResolvedValue(list)

    const store = makeStore()
    await store.dispatch(fetchAuthorsIndex())

    expect(store.getState().storeAuthors.authorsIndex).toEqual({ 2: list[0] })
  })

  it('fetches a full author by id', async() => {
    const author = { id: 3, fullname: 'Cara' }
    apiClient.getAuthorFull.mockResolvedValue(author)

    const store = makeStore()
    await store.dispatch(fetchAuthorFull(3))

    expect(apiClient.getAuthorFull).toHaveBeenCalledWith(3)
    expect(store.getState().storeAuthors.authorsFull).toEqual({ 3: author })
  })
})
