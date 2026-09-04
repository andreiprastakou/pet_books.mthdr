import { beforeEach, describe, expect, it, vi } from 'vitest'

import apiClient from 'store/books/apiClient'

vi.mock('jquery', () => ({
  default: {
    ajax: vi.fn(),
  },
}))

import jQuery from 'jquery'

describe('books apiClient', () => {
  beforeEach(() => {
    jQuery.ajax.mockReset()
  })

  it('fetches years and index entries', async() => {
    jQuery.ajax
      .mockResolvedValueOnce([1900, 2000])
      .mockResolvedValueOnce([{
        id: 1,
        title: 'One',
        author_ids: [2],
        tag_ids: [],
        popularity: 1,
        global_rank: 1,
        cover_design_id: null,
        small: false,
      }])

    const years = await apiClient.getBooksYears({ authorId: 2, tagIds: [3] })
    const index = await apiClient.getBooksIndex({ ids: [1] })

    expect(jQuery.ajax.mock.calls[0][0].url).toContain('/api/books/years.json?')
    expect(jQuery.ajax.mock.calls[0][0].url).toContain('author_id=2')
    expect(years).toEqual([1900, 2000])
    expect(index[0]).toMatchObject({ id: 1, authorIds: [2] })
  })

  it('fetches refs, full entry, and search results', async() => {
    jQuery.ajax
      .mockResolvedValueOnce({
        total: 1,
        list: [{ id: 5, year: 1910, author_ids: [1] }],
      })
      .mockResolvedValueOnce({ id: 5, year: 1910, author_ids: [1] })
      .mockResolvedValueOnce({
        id: 5,
        title: 'Five',
        original_title: null,
        author_ids: [1],
        year_published: 1910,
        tag_ids: [],
        wiki_url: null,
        generic_links: [],
      })
      .mockResolvedValueOnce([{
        book_id: 5,
        title: 'Five',
        year: 1910,
        author_ids: [1],
      }])

    const refs = await apiClient.getBooksRefs({ page: 1, perPage: 16, sortBy: 'name' })
    const ref = await apiClient.getBookRefEntry(5)
    const full = await apiClient.getBookFull(5)
    const search = await apiClient.search('five')

    expect(refs).toEqual({
      total: 1,
      books: [{ id: 5, year: 1910, authorIds: [1] }],
    })
    expect(ref).toEqual({ id: 5, year: 1910, authorIds: [1] })
    expect(full).toMatchObject({ id: 5, title: 'Five', authorIds: [1] })
    expect(search).toEqual([{
      bookId: 5,
      title: 'Five',
      year: 1910,
      authorIds: [1],
    }])
  })

  it('fetches a single index entry', async() => {
    jQuery.ajax.mockResolvedValue({
      id: 8,
      title: 'Eight',
      author_ids: [],
      tag_ids: [],
      popularity: 0,
      global_rank: 8,
      cover_design_id: null,
      small: false,
    })

    const entry = await apiClient.getBooksIndexEntry(8)
    expect(jQuery.ajax).toHaveBeenCalledWith({
      url: '/api/books/index_entries/8.json',
    })
    expect(entry.id).toBe(8)
  })
})
