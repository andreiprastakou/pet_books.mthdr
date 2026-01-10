import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'imageModal',
  initialState: {
    imageSrc: null,
  },
  reducers: {
    setImageSrc: (state, action) => {
      state.imageSrc = action.payload
    },
  }
})

export default slice.reducer
