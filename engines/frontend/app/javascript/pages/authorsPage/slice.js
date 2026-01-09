import { createSlice } from '@reduxjs/toolkit'

const DEFAULT_SORT_BY = 'years'
const DEFAULT_PAGE = 1
const DEFAULT_PER_PAGE = 40

export const slice = createSlice({
  name: 'authorsPage',
  initialState: {
    authorIds: [],
    authorsTotal: 0,
    listFilter: {},
    sortBy: DEFAULT_SORT_BY,
    page: DEFAULT_PAGE,
    perPage: DEFAULT_PER_PAGE,
  },
  reducers: {
    assignAuthorIds: (state, action) => {
      const ids = action.payload
      state.authorIds = ids
    },

    assignAuthorsTotal: (state, action) => {
      const number = action.payload
      state.authorsTotal = number
    },

    assignSortBy: (state, action) => {
      const newSortBy = action.payload || DEFAULT_SORT_BY
      state.sortBy = newSortBy
    },

    assignPage: (state, action) => {
      const page = action.payload || DEFAULT_PAGE
      state.page = page
    },

    assignPerPage: (state, action) => {
      const perPage = action.payload || DEFAULT_PER_PAGE
      state.perPage = perPage
    },

    clearState: state => {
      state.authorsTotal = 0
      state.page = DEFAULT_PAGE
    },
  }
})

export default slice.reducer
