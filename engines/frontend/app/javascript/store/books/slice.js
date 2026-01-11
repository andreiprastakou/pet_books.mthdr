import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'storeBooks',
  initialState: {
    booksIndex: {},
    booksRefs: {},
    bookDetailsCurrent: {},
    requestedBookId: null,
  },
  reducers: {
    addBook: (state, action) => {
      const book = action.payload
      state.booksIndex[book.id] = book
    },

    addBooks: (state, action) => {
      const books = action.payload
      books.forEach(book => {
        state.booksIndex[book.id] = book
      })
    },

    addBooksRefs: (state, action) => {
      const refs = action.payload
      refs.forEach(entry => {
        state.booksRefs[entry.id] = entry
      })
    },

    clearBooksRefs: state => {
      state.booksRefs = {}
    },

    setCurrentBookDetails: (state, action) => {
      state.bookDetailsCurrent = action.payload
    },

    setRequestedBookId: (state, action) => {
      state.requestedBookId = action.payload
    },
  }
})

export default slice.reducer
