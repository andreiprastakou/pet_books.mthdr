import { beforeEach, describe, expect, it, vi } from 'vitest'

import apiClient from 'store/authors/apiClient'

vi.mock('jquery', () => ({
  default: {
    ajax: vi.fn(),
  },
}))

import jQuery from 'jquery'

describe('authors apiClient', () => {
  beforeEach(() => {
    jQuery.ajax.mockReset()
  })

  it('fetches and parses author refs', async() => {
    jQuery.ajax.mockResolvedValue([{ id: 1, fullname: 'Ada' }])

    const result = await apiClient.getAuthorsRefs()

    expect(jQuery.ajax).toHaveBeenCalledWith({ url: '/api/authors/ref_entries.json' })
    expect(result).toEqual([{ id: 1, fullname: 'Ada' }])
  })

  it('fetches and parses authors index with query params', async() => {
    jQuery.ajax.mockResolvedValue({
      total: 1,
      list: [{
        id: 2,
        fullname: 'Bob',
        books_count: 1,
        thumb_url: '/b.png',
        birth_year: 1900,
        rank: 5,
      }],
    })

    const result = await apiClient.getAuthorsIndex({ page: 2, perPage: 10, sortBy: 'name' })

    expect(jQuery.ajax.mock.calls[0][0].url).toContain('/api/authors/index_entries.json?')
    expect(jQuery.ajax.mock.calls[0][0].url).toContain('page=2')
    expect(jQuery.ajax.mock.calls[0][0].url).toContain('per_page=10')
    expect(jQuery.ajax.mock.calls[0][0].url).toContain('sort_by=name')
    expect(result).toEqual({
      total: 1,
      list: [{
        id: 2,
        fullname: 'Bob',
        booksCount: 1,
        thumbUrl: '/b.png',
        birthYear: 1900,
        rank: 5,
      }],
    })
  })

  it('fetches a full author and search results', async() => {
    jQuery.ajax
      .mockResolvedValueOnce({
        id: 3,
        fullname: 'Cara',
        books_count: 2,
        photo_thumb_url: '/t.png',
        photo_full_url: '/f.png',
        birth_year: 1800,
        death_year: null,
        tag_ids: [],
        popularity: 1,
        rank: 1,
        reference: null,
      })
      .mockResolvedValueOnce([{ author_id: 3, label: 'Cara' }])

    const full = await apiClient.getAuthorFull(3)
    const search = await apiClient.search('cara')

    expect(jQuery.ajax.mock.calls[0][0].url).toBe('/api/authors/full_entries/3.json')
    expect(full.id).toBe(3)
    expect(full.fullname).toBe('Cara')
    expect(jQuery.ajax.mock.calls[1][0].url).toContain('/api/authors/search.json?key=cara')
    expect(search).toEqual([{ authorId: 3, label: 'Cara' }])
  })
})
