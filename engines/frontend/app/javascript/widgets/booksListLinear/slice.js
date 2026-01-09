import { createSlice } from '@reduxjs/toolkit'

const DEFAULT_SORT_BY = 'name'
const DEFAULT_PAGE = 1
const DEFAULT_PER_PAGE = 16

export const slice = createSlice({
  name: 'booksListLinear',
  initialState: {
    bookIds: [],
    booksTotal: 0,
    listFilter: {},
    sortBy: DEFAULT_SORT_BY,
    page: DEFAULT_PAGE,
    perPage: DEFAULT_PER_PAGE,
  },
  reducers: {
    assignBookIds: (state, action) => {
      const ids = action.payload
      state.bookIds = ids
    },

    assignBooksTotal: (state, action) => {
      const number = action.payload
      state.booksTotal = number
    },

    assignFilter: (state, action) => {
      const filterQuery = action.payload
      state.listFilter = filterQuery
    },

    assignSortBy: (state, action) => {
      const newSortBy = action.payload || state.sortBy || DEFAULT_SORT_BY
      state.sortBy = newSortBy
    },

    assignPage: (state, action) => {
      const page = action.payload || DEFAULT_PAGE
      state.page = page
    },

    assignPerPage: (state, action) => {
      const perPage = action.payload || state.perPage || DEFAULT_PER_PAGE
      state.perPage = perPage
    },

    clearState: state => {
      state.bookIds = []
      state.booksTotal = 0
      state.listFilter = {}
      state.page = DEFAULT_PAGE
    },
  }
})

export default slice.reducer
