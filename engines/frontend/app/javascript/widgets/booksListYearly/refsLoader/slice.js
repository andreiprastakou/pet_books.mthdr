import { difference, uniq } from 'lodash'
import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'booksListYearlyRefs',
  initialState: {
    yearsInLoading: [],
    yearsLoaded: [],
    yearsToLoad: [],
  },
  reducers: {
    clearState: state => {
      state.yearsLoaded = []
      state.yearsInLoading = []
      state.yearsToLoad = []
    },

    markBooksYearsAsLoaded: (state, action) => {
      const books = action.payload
      state.yearsLoaded = uniq([...state.yearsLoaded, ...books.map(b => b.year)])
    },

    addYearsToLoad: (state, action) => {
      const years = action.payload
      state.yearsToLoad = uniq([...state.yearsToLoad, ...difference(years, state.yearsLoaded)])
    },

    markYearsAsLoading: state => {
      const years = state.yearsToLoad
      state.yearsToLoad = []
      state.yearsInLoading = uniq([...state.yearsInLoading, ...years])
    },

    markYearsAsLoaded: (state, action) => {
      const years = action.payload
      state.yearsLoaded = uniq([...state.yearsLoaded, ...years])
      state.yearsInLoading = difference(state.yearsInLoading, years)
    },
  }
})

export default slice.reducer
