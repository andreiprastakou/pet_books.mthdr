import { selectCurrentBookId } from 'store/axis/selectors'

const localState = state => state.storeBooks

export const selectCurrentBookDetails = () => state => localState(state).bookDetailsCurrent

export const selectBooksIndexEntry = id => state => localState(state).booksIndex[id]

export const selectBooksIndexIds = () => state => Object.keys(localState(state).booksIndex).map(k => parseInt(k))

export const selectCurrentBookIndexEntry = () => state => {
  const id = selectCurrentBookId()(state)
  return selectBooksIndexEntry(id)(state)
}

export const selectBookRef = id => state => localState(state).booksRefs[id]

export const selectCurrentBookRef = () => state => {
  const id = selectCurrentBookId()(state)
  return selectBookRef(id)(state)
}

export const selectRequestedBookId = () => state => localState(state).requestedBookId
