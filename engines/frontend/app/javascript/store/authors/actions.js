import { slice } from 'store/authors/slice'
import apiClient from 'store/authors/apiClient'

export const {
  addAuthorFull,
  addAuthorsIndexEntries,
  assignAuthorsIndex,
  assignAuthorsRefs,
  setAuthorPin,
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

export const saveAuthorPin = (authorId, pinned) => async dispatch => {
  const payload = await apiClient.setAuthorPin(authorId, pinned)
  dispatch(setAuthorPin({ authorId: payload.author_id, pinned: payload.pinned }))
}

export const fetchAuthorFull = id => async dispatch => {
  const authorFull = await apiClient.getAuthorFull(id)
  dispatch(addAuthorFull(authorFull))
}
