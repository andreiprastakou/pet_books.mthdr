import difference from 'lodash/difference'
import { slice } from 'store/books/slice'
import { selectCurrentBookId } from 'store/axis/selectors'

import {
  selectBooksIndexIds,
  selectBookRef,
} from 'store/books/selectors'
export const {
  addBooks,
  addBooksRefs,
  clearBooksRefs,
  setBookDetails,
  setBookPin,
  setBookRead,
  setCurrentBookDetails,
  setRequestedBookId,
} = slice.actions

import apiClient from 'store/books/apiClient'

export const fetchCurrentBookDetails = () => async(dispatch, getState) => {
  const currentId = selectCurrentBookId()(getState())
  if (!currentId) return

  const details = await apiClient.getBookFull(currentId)
  dispatch(setCurrentBookDetails(details))
}

export const saveBookPin = (bookId, pinned) => async dispatch => {
  const payload = await apiClient.setBookPin(bookId, pinned)
  dispatch(setBookPin({ bookId: payload.book_id, pinned: payload.pinned }))
}

export const saveBookRead = (bookId, read) => async dispatch => {
  const payload = await apiClient.setBookRead(bookId, read)
  dispatch(setBookRead({ bookId: payload.book_id, read: payload.read }))
}

export const fetchBookDetails = bookId => async dispatch => {
  const details = await apiClient.getBookFull(bookId)
  dispatch(setBookDetails(details))
}

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

  const batches = []
  for (let index = 0; index < idsToLoad.length; index += 50)
    batches.push(idsToLoad.slice(index, index + 50))

  await Promise.all(batches.map(batch =>
    apiClient.getBooksIndex({ ids: batch }).then(books => {
      dispatch(addBooks(books))
    })
  ))
}

