import { beforeEach, describe, expect, it, vi } from 'vitest'

import apiClient from 'store/series/apiClient'

vi.mock('jquery', () => ({
  default: {
    ajax: vi.fn(),
  },
}))

import jQuery from 'jquery'

describe('series apiClient', () => {
  beforeEach(() => {
    jQuery.ajax.mockReset()
  })

  it('fetches index, refs, and search results', async() => {
    jQuery.ajax
      .mockResolvedValueOnce([{ id: 1, name: 'Earthsea' }])
      .mockResolvedValueOnce({
        id: 1,
        name: 'Earthsea',
        wiki_url: 'https://wiki',
        generic_links: [],
      })
      .mockResolvedValueOnce([{ id: 1, name: 'Earthsea' }])
      .mockResolvedValueOnce([{ series_id: 1, label: 'Earthsea' }])

    const index = await apiClient.getSeriesIndex()
    const entry = await apiClient.getSeriesIndexEntry(1)
    const refs = await apiClient.getSeriesRefs()
    const search = await apiClient.search('Earth')

    expect(jQuery.ajax.mock.calls[0][0].url).toBe('/api/series/index_entries.json')
    expect(index[0]).toMatchObject({ id: 1, name: 'Earthsea' })
    expect(entry).toMatchObject({ name: 'Earthsea', wikiUrl: 'https://wiki' })
    expect(refs[0]).toEqual({ id: 1, name: 'Earthsea' })
    expect(search).toEqual([{ seriesId: 1, label: 'Earthsea' }])
  })
})
