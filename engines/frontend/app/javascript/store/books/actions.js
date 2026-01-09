import { difference } from 'lodash'
import { slice } from 'store/books/slice'
import { selectCurrentBookId } from 'store/axis/selectors'

import {
  selectBooksIndexIds,
  selectBookRef,
} from 'store/books/selectors'
export const {
  addBook,
  addBooks,
  addBooksRefs,
  clearBooksRefs,
  setDefaultBookImageUrl,
  setCurrentBookDetails,
  setRequestedBookId,
} = slice.actions

import apiClient from 'store/books/apiClient'

export const showBook = bookId => (dispatch, getState) => {
  if (!bookId) throw new Error('Trying to show nothing!')

  const state = getState()
  const currentBookId = selectCurrentBookId()(state)
  const bookRef = selectBookRef(bookId)(state)
  if (!bookRef) throw new Error(`Book #${bookId} is missing! Cannot show it.`)

  if (bookId !== currentBookId)
    dispatch(setRequestedBookId(bookId))
}

export const fetchMissingBookIndexEntries = ids => async(dispatch, getState) => {
  const state = getState()
  const loadedIds = selectBooksIndexIds()(state)
  const idsToLoad = difference(ids, loadedIds)
  if (idsToLoad.length < 1) return
  await apiClient.getBooksIndex({ ids: idsToLoad }).then(books => {
    dispatch(addBooks(books))
  })
}
