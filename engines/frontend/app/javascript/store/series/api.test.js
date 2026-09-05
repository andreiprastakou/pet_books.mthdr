import { describe, expect, it } from 'vitest'

import SeriesIndexEntry from 'store/series/api/SeriesIndexEntry'
import SeriesRef from 'store/series/api/SeriesRef'
import SeriesSearchEntry from 'store/series/api/SeriesSearchEntry'

describe('series API models', () => {
  it('parses SeriesIndexEntry, SeriesRef, and SeriesSearchEntry', () => {
    expect(SeriesIndexEntry.parse({
      id: 1,
      name: 'Earthsea',
      wiki_url: 'https://wiki',
      generic_links: [{ name: 'official', url: 'https://x' }],
    })).toEqual({
      id: 1,
      name: 'Earthsea',
      wikiUrl: 'https://wiki',
      genericLinks: [{ name: 'official', url: 'https://x' }],
    })

    expect(SeriesRef.parse({ id: 2, name: 'Foundation' })).toEqual({
      id: 2,
      name: 'Foundation',
    })

    expect(SeriesSearchEntry.parse({ series_id: 3, label: 'Dune' })).toEqual({
      seriesId: 3,
      label: 'Dune',
    })
  })
})
