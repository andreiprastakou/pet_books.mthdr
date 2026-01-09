import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'notifications',
  initialState: {
    messages: [],
  },
  reducers: {
    addMessage: (state, action) => {
      const message = action.payload
      state.messages.push({ ...message, id: new Date().getTime() })
    },

    removeMessage: (state, action) => {
      const messageId = action.payload
      state.messages = state.messages.filter(message => message.id !== messageId)
    }
  }
})

export default slice.reducer
