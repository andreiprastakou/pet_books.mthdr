import { createSlice } from '@reduxjs/toolkit'

export const slice = createSlice({
  name: 'storeBooks',
  initialState: {
    booksIndex: {},
    booksRefs: {},
    bookDetailsById: {},
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

    setBookDetails: (state, action) => {
      const details = action.payload
      state.bookDetailsById[details.id] = details
    },

    setCurrentBookDetails: (state, action) => {
      state.bookDetailsCurrent = action.payload
    },

    setRequestedBookId: (state, action) => {
      state.requestedBookId = action.payload
    },

    setBookRead: (state, action) => {
      const { bookId, read } = action.payload
      if (state.bookDetailsCurrent?.id === bookId) state.bookDetailsCurrent.read = read

      const stored = state.bookDetailsById[bookId]
      if (stored) stored.read = read
    },
  }
})

export default slice.reducer
