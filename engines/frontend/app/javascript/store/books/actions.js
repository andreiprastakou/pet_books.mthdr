import { difference, pull } from 'lodash'
import { slice } from 'store/books/slice'
import { selectCurrentBookId } from 'store/axis/selectors'
import { selectTagNames } from 'store/tags/selectors'

import {
  selectBooksIndexEntry,
  selectBooksIndexIds,
  selectBookRef,
} from 'store/books/selectors'
export const {
  addBook,
  addBooks,
  addBooksRefs,
  clearBooksRefs,
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

export const reloadBook = id => async dispatch => {
  const book = await apiClient.getBooksIndexEntry(id)
  dispatch(addBook(book))
  dispatch(showBook(id))
}

export const addTagToBook = (id, tagName) => (dispatch, getState) => {
  const state = getState()
  const book = selectBooksIndexEntry(id)(state)
  const tagNames = selectTagNames(book.tagIds)(state)
  tagNames.push(tagName)
  apiClient.updateBook(id, { tagNames }).then(() =>
    dispatch(reloadBook(id))
  )
}

export const removeTagFromBook = (id, tagName) => (dispatch, getState) => {
  const state = getState()
  const book = selectBooksIndexEntry(id)(state)
  const tagNames = selectTagNames(book.tagIds)(state)
  pull(tagNames, tagName)
  tagNames.push('')
  apiClient.updateBook(id, { tagNames }).then(() =>
    dispatch(reloadBook(id))
  )
}
