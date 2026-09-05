import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'storeSeries',
  initialState: {
    seriesIndex: {},
    seriesRefs: {},
    refsLoaded: false,
  },
  reducers: {
    addSeriesIndexEntry: (state, action) => {
      const entry = action.payload
      state.seriesIndex[entry.id] = entry
    },

    assignSeriesIndex: (state, action) => {
      const entries = action.payload
      state.seriesIndex = {}
      entries.forEach(entry => {
        state.seriesIndex[entry.id] = entry
      })
    },

    assignSeriesRefs: (state, action) => {
      const seriesRefs = action.payload
      state.seriesRefs = {}
      seriesRefs.forEach(seriesRef => {
        state.seriesRefs[seriesRef.id] = seriesRef
      })
      state.refsLoaded = true
    },
  }
})

export default slice.reducer
