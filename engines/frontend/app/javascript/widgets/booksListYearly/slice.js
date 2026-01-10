import { uniq } from 'lodash'
import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'booksListYearly',
  initialState: {
    bookShiftDirectionHorizontal: null,
    bookIdsCurrentInYear: {},
    filters: {},
    years: [],
  },
  reducers: {
    clearState: state => {
      state.bookShiftDirectionHorizontal = null
      state.bookIdsCurrentInYear = {}
      state.years = []
    },

    addYears: (state, action) => {
      const years = action.payload
      state.years = uniq([...state.years, ...years]).sort()
    },

    setBookShiftDirectionHorizontal: (state, action) => {
      state.bookShiftDirectionHorizontal = action.payload
    },

    setCurrentBookForYear: (state, action) => {
      const { id, year } = action.payload
      state.bookIdsCurrentInYear[year] = id
    },

    setFilters: (state, action) => {
      const filters = action.payload
      state.filters = filters
    },

    setYears: (state, action) => {
      state.years = action.payload.slice()
    },
  }
})

export default slice.reducer
