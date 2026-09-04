import { describe, expect, it } from 'vitest'

import TagIndexEntry from 'store/tags/api/TagIndexEntry'
import TagRef from 'store/tags/api/TagRef'
import TagSearchEntry from 'store/tags/api/TagSearchEntry'

describe('tags API models', () => {
  it('parses TagIndexEntry, TagRef, and TagSearchEntry', () => {
    expect(TagIndexEntry.parse({
      id: 1,
      name: 'fiction',
      category_id: 10,
      book_connections_count: 5,
      author_connections_count: 2,
    })).toEqual({
      id: 1,
      name: 'fiction',
      categoryId: 10,
      bookConnectionsCount: 5,
      authorConnectionsCount: 2,
    })

    expect(TagRef.parse({
      id: 2,
      name: 'classic',
      category_id: 10,
      connections_count: 9,
    })).toEqual({
      id: 2,
      name: 'classic',
      categoryId: 10,
      connectionsCount: 9,
    })

    expect(TagSearchEntry.parse({ tag_id: 3, label: 'noir' })).toEqual({
      tagId: 3,
      label: 'noir',
    })
  })
})
