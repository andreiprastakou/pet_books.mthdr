import { describe, expect, it } from 'vitest'

import AuthorFull from 'store/authors/api/AuthorFull'
import AuthorIndexEntry from 'store/authors/api/AuthorIndexEntry'
import AuthorRef from 'store/authors/api/AuthorRef'
import AuthorSearchEntry from 'store/authors/api/AuthorSearchEntry'

describe('authors API models', () => {
  it('parses AuthorFull', () => {
    expect(AuthorFull.parse({
      id: 1,
      fullname: 'Ada',
      books_count: 3,
      photo_thumb_url: '/t.png',
      photo_full_url: '/f.png',
      birth_year: 1815,
      death_year: 1852,
      tag_ids: [1, 2],
      popularity: 9,
      rank: 2,
      reference: 'ref',
    })).toEqual({
      id: 1,
      fullname: 'Ada',
      booksCount: 3,
      thumbUrl: '/t.png',
      imageUrl: '/f.png',
      birthYear: 1815,
      deathYear: 1852,
      tagIds: [1, 2],
      popularity: 9,
      rank: 2,
      reference: 'ref',
    })
  })

  it('parses AuthorIndexEntry, AuthorRef, and AuthorSearchEntry', () => {
    expect(AuthorIndexEntry.parse({
      id: 2,
      fullname: 'Bob',
      books_count: 1,
      thumb_url: '/b.png',
      birth_year: 1900,
      rank: 5,
    })).toEqual({
      id: 2,
      fullname: 'Bob',
      booksCount: 1,
      thumbUrl: '/b.png',
      birthYear: 1900,
      rank: 5,
    })

    expect(AuthorRef.parse({ id: 3, fullname: 'Cara' })).toEqual({
      id: 3,
      fullname: 'Cara',
    })

    expect(AuthorSearchEntry.parse({ author_id: 4, label: 'Dan' })).toEqual({
      authorId: 4,
      label: 'Dan',
    })
  })
})
