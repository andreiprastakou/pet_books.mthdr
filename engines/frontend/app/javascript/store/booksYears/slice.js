import { sortBy, uniq } from 'lodash'
import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'booksYears',
  initialState: {
    years: [],
  },
  reducers: {
    clearState: state => {
      state.years = []
    },

    addYears: (state, action) => {
      const years = action.payload
      state.years = uniq(sortBy([...state.years, ...years]))
    },
  }
})

export default slice.reducer
