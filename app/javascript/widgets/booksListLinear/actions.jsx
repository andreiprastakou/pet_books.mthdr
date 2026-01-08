import apiClient from 'store/books/apiClient'
import { selectCurrentBookId } from 'store/axis/selectors'
import { selectCurrentBookRef } from 'store/books/selectors'
import {
  addBooksRefs,
  fetchMissingBookIndexEntries,
  setRequestedBookId,
  showBook,
} from 'store/books/actions'
import { selectBookIds, selectFilter, selectPage, selectPerPage, selectSortBy } from 'widgets/booksListLinear/selectors'
import { slice } from 'widgets/booksListLinear/slice'
export const {
  assignBookIds,
  assignBooksTotal,
  assignFilter,
  assignSortBy,
  assignPage,
  assignPerPage,
  clearState: clearListInnerState,
} = slice.actions

export const fetchBooks = () => (dispatch, getState) => {
  const state = getState()
  const query = {
    ...selectFilter()(state),
    page: selectPage()(state),
    perPage: selectPerPage()(state),
    sortBy: selectSortBy()(state),
  }
  return apiClient.getBooksRefs(query).then(({ books, total }) => {
    dispatch(addBooksRefs(books))
    dispatch(assignBookIds(books.map(book => book.id)))
    dispatch(assignBooksTotal(total))
    if (books.length > 0) {
      const ids = books.map(book => book.id)
      dispatch(fetchMissingBookIndexEntries(ids))
    }
  })
}

export const shiftSelection = shift => (dispatch, getState) => {
  const state = getState()
  const currentBookRef = selectCurrentBookRef()(state)
  const allBookIds = selectBookIds()(state)
  const currentIndex = allBookIds.indexOf(currentBookRef.id)
  let targetIndex = currentIndex + shift
  if (targetIndex < 0)  targetIndex = allBookIds.length - 1 
  if (targetIndex >= allBookIds.length)  targetIndex = 0 

  dispatch(setRequestedBookId(allBookIds[targetIndex]))
}

export const setupBooksListSelection = () => (dispatch, getState) => {
  const currentBookRef = selectCurrentBookRef()(getState())
  if (currentBookRef) 
    dispatch(showBook(currentBookRef.id))
  else 
    dispatch(switchToFirstBook())
}

export const switchToFirstBook = () => (dispatch, getState) => {
  const state = getState()
  const ids = selectBookIds()(state)
  const currentBookId = selectCurrentBookId()(state)
  if (ids.includes(currentBookId)) return

  dispatch(setRequestedBookId(ids[0]))
}

export const clearListState = () => dispatch => {
  dispatch(clearListInnerState())
}
