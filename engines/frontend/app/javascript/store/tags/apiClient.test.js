import { beforeEach, describe, expect, it, vi } from 'vitest'

import apiClient from 'store/tags/apiClient'

vi.mock('jquery', () => ({
  default: {
    ajax: vi.fn(),
  },
}))

import jQuery from 'jquery'

describe('tags apiClient', () => {
  beforeEach(() => {
    jQuery.ajax.mockReset()
  })

  it('fetches index, refs, categories, and search results', async() => {
    jQuery.ajax
      .mockResolvedValueOnce([{
        id: 1,
        name: 'fiction',
        category_id: 10,
        book_connections_count: 5,
        author_connections_count: 2,
      }])
      .mockResolvedValueOnce({
        id: 1,
        name: 'fiction',
        category_id: 10,
        book_connections_count: 5,
        author_connections_count: 2,
      })
      .mockResolvedValueOnce([{
        id: 1,
        name: 'fiction',
        category_id: 10,
        connections_count: 7,
      }])
      .mockResolvedValueOnce([{ id: 10, name: 'Genre' }])
      .mockResolvedValueOnce([{ tag_id: 1, label: 'fiction' }])

    const index = await apiClient.getTagsIndex()
    const entry = await apiClient.getTagsIndexEntry(1)
    const refs = await apiClient.getTagsRefs()
    const categories = await apiClient.getCategories()
    const search = await apiClient.search('fic')

    expect(jQuery.ajax.mock.calls[0][0].url).toBe('/api/tags/index_entries.json')
    expect(index[0]).toMatchObject({ id: 1, categoryId: 10 })
    expect(entry.name).toBe('fiction')
    expect(refs[0]).toMatchObject({ connectionsCount: 7 })
    expect(categories).toEqual([{ id: 10, name: 'Genre' }])
    expect(search).toEqual([{ tagId: 1, label: 'fiction' }])
  })
})
