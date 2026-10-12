import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'storePinBoard',
  initialState: {
    authors: [],
    books: [],
    series: [],
  },
  reducers: {
    setPinBoard: (state, action) => {
      state.authors = action.payload.authors
      state.books = action.payload.books
      state.series = action.payload.series
    },
  },
})

export default slice.reducer
