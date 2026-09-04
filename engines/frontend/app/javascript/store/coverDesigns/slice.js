import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'storeCoverDesigns',
  initialState: {
    coverDesigns: {},
    coverDesignsLoaded: false,
  },
  reducers: {
    assignCoverDesigns: (state, action) => {
      const coverDesigns = action.payload
      state.coverDesigns = {}
      coverDesigns.forEach(coverDesign => {
        state.coverDesigns[coverDesign.id] = coverDesign
      })
      state.coverDesignsLoaded = true
    },
  }
})

export default slice.reducer
