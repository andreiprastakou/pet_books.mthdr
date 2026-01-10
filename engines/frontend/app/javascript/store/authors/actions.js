import { slice } from 'store/authors/slice'
import apiClient from 'store/authors/apiClient'

import { setCurrentAuthorId } from 'store/axis/actions'
export const {
  addAuthorFull,
  addAuthorIndexEntry,
  addAuthorsIndexEntries,
  addAuthorRef,
  assignAuthorsIndex,
  assignAuthorsRefs,
  setDefaultAuthorImageUrl,
} = slice.actions

export const fetchAuthorsRefs = () => async dispatch => {
  const authorRefs = await apiClient.getAuthorsRefs()
  dispatch(assignAuthorsRefs(authorRefs))
}

export const fetchAuthorsIndex = () => async dispatch => {
  const authorIndex = await apiClient.getAuthorsIndex()
  dispatch(assignAuthorsIndex(authorIndex))
}

export const fetchAuthorFull = id => async dispatch => {
  const authorFull = await apiClient.getAuthorFull(id)
  dispatch(addAuthorFull(authorFull))
}

export const fetchAuthorIndexEntry = id => async dispatch => {
  const authorIndexEntry = await apiClient.getAuthorIndexEntry(id)
  dispatch(addAuthorIndexEntry(authorIndexEntry))
}

export const fetchAuthorRef = id => async dispatch => {
  const authorRef = await apiClient.getAuthorRef(id)
  dispatch(addAuthorRef(authorRef))
}

export const reloadAuthor = id => dispatch => {
  Promise.all([
    dispatch(fetchAuthorFull(id)),
    dispatch(fetchAuthorIndexEntry(id)),
    dispatch(fetchAuthorRef(id)),
  ]).then(() => {
    dispatch(setCurrentAuthorId(null))
    dispatch(setCurrentAuthorId(id))
  })
}
