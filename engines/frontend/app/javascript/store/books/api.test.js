import { describe, expect, it } from 'vitest'

import BookFull from 'store/books/api/BookFull'
import BookIndexEntry from 'store/books/api/BookIndexEntry'
import BookRefEntry from 'store/books/api/BookRefEntry'
import BookSearchEntry from 'store/books/api/BookSearchEntry'

describe('books API models', () => {
  it('parses BookFull and BookIndexEntry with camelCase overlays', () => {
    expect(BookFull.parse({
      id: 1,
      title: 'One',
      original_title: 'Uno',
      author_ids: [9],
      year_published: 1900,
      tag_ids: [2],
      series_ids: [4],
      wiki_url: 'https://wiki',
      generic_links: [{ url: 'https://x' }],
    })).toMatchObject({
      id: 1,
      title: 'One',
      originalTitle: 'Uno',
      authorIds: [9],
      yearPublished: 1900,
      tagIds: [2],
      seriesIds: [4],
      wikiUrl: 'https://wiki',
      genericLinks: [{ url: 'https://x' }],
    })

    expect(BookIndexEntry.parse({
      id: 2,
      title: 'Two',
      author_ids: [1],
      tag_ids: [3],
      popularity: 8,
      global_rank: 4,
      cover_design_id: 7,
      small: true,
    })).toMatchObject({
      id: 2,
      authorIds: [1],
      tagIds: [3],
      popularity: 8,
      globalRank: 4,
      coverDesignId: 7,
      small: true,
    })
  })

  it('parses BookRefEntry and BookSearchEntry', () => {
    expect(BookRefEntry.parse({ id: 3, year: 1999, author_ids: [1, 2] })).toEqual({
      id: 3,
      year: 1999,
      authorIds: [1, 2],
    })

    expect(BookSearchEntry.parse({
      book_id: 4,
      title: 'Four',
      year: 2001,
      author_ids: [5],
    })).toEqual({
      bookId: 4,
      title: 'Four',
      year: 2001,
      authorIds: [5],
    })
  })
})
