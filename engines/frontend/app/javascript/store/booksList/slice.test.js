import { describe, expect, it } from 'vitest'

import reducer, { slice } from 'store/booksList/slice'
import {
  selectBookIds,
  selectBooksTotal,
  selectFilter,
  selectPage,
  selectPerPage,
  selectSortBy,
} from 'store/booksList/selectors'

const {
  assignBookIds,
  assignBooksTotal,
  assignFilter,
  assignPage,
  assignPerPage,
  assignSortBy,
  clearState,
} = slice.actions

describe('booksList slice', () => {
  it('starts with default list paging and sorting', () => {
    expect(reducer(undefined, { type: 'unknown' })).toEqual({
      bookIds: [],
      booksTotal: 0,
      listFilter: {},
      sortBy: 'name',
      page: 1,
      perPage: 16,
    })
  })

  it('assigns list fields', () => {
    let state = reducer(undefined, assignBookIds([1, 2, 3]))
    state = reducer(state, assignBooksTotal(30))
    state = reducer(state, assignFilter({ authorId: 9 }))
    state = reducer(state, assignSortBy('year'))
    state = reducer(state, assignPage(2))
    state = reducer(state, assignPerPage(8))

    expect(state).toEqual({
      bookIds: [1, 2, 3],
      booksTotal: 30,
      listFilter: { authorId: 9 },
      sortBy: 'year',
      page: 2,
      perPage: 8,
    })
  })

  it('falls back to defaults for blank sort, page, and perPage', () => {
    const previous = reducer(undefined, assignSortBy('year'))
    const withBlankSort = reducer(previous, assignSortBy(null))
    expect(withBlankSort.sortBy).toBe('year')

    expect(reducer(previous, assignPage(null)).page).toBe(1)
    expect(reducer(previous, assignPerPage(null)).perPage).toBe(16)
  })

  it('clears list fields but keeps sort and perPage', () => {
    let state = reducer(undefined, assignBookIds([1]))
    state = reducer(state, assignBooksTotal(5))
    state = reducer(state, assignFilter({ tagIds: [1] }))
    state = reducer(state, assignSortBy('year'))
    state = reducer(state, assignPage(3))
    state = reducer(state, assignPerPage(8))
    state = reducer(state, clearState())

    expect(state).toEqual({
      bookIds: [],
      booksTotal: 0,
      listFilter: {},
      sortBy: 'year',
      page: 1,
      perPage: 8,
    })
  })
})

describe('booksList selectors', () => {
  const state = {
    booksList: {
      bookIds: [4, 5],
      booksTotal: 2,
      listFilter: { years: [1900] },
      sortBy: 'year',
      page: 2,
      perPage: 8,
    },
  }

  it('reads list configuration from state', () => {
    expect(selectBookIds()(state)).toEqual([4, 5])
    expect(selectBooksTotal()(state)).toBe(2)
    expect(selectFilter()(state)).toEqual({ years: [1900] })
    expect(selectSortBy()(state)).toBe('year')
    expect(selectPage()(state)).toBe(2)
    expect(selectPerPage()(state)).toBe(8)
  })
})
