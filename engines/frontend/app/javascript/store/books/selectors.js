import { selectCurrentBookId } from 'store/axis/selectors'

const localState = state => state.storeBooks

export const selectBookDefaultImageUrl = () => state => localState(state).defaultCoverUrl

export const selectCurrentBookDetails = () => state => localState(state).bookDetailsCurrent

export const selectBooksIndexEntry = id => state => localState(state).booksIndex[id]

export const selectBooksIndexIds = () => state => Object.keys(localState(state).booksIndex).map(k => parseInt(k))

export const selectBooksIndex = () => state => Object.values(localState(state).booksIndex)

export const selectCurrentBookIndexEntry = () => state => {
  const id = selectCurrentBookId()(state)
  return selectBooksIndexEntry(id)(state)
}

export const selectBooksRefsByYear = year => state =>
  Object.values(localState(state).booksRefs).filter(ref => ref.year === year)

export const selectBookRef = id => state => localState(state).booksRefs[id]

export const selectBooksRefIds = () => state => Object.keys(localState(state).booksRefs).map(id => parseInt(id))

export const selectCurrentBookRef = () => state => {
  const id = selectCurrentBookId()(state)
  return selectBookRef(id)(state)
}

export const selectBookPopularities = ids => state => ids.map(id => selectBooksIndexEntry(id)(state)?.popularity)

export const selectRequestedBookId = () => state => localState(state).requestedBookId
