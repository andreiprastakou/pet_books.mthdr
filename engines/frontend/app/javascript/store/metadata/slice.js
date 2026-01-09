import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'metadata',
  initialState: {
    pageIsLoading: false,
  },
  reducers: {
    setPageIsLoading: (state, action) => {
      state.pageIsLoading = Boolean(action.payload)
    },
  }
})

export default slice.reducer
