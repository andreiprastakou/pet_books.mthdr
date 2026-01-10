import { slice } from 'store/tags/slice'
import apiClient from 'store/tags/apiClient'

import { selectTagIndexEntry } from 'store/tags/selectors'
export const {
  addTagIndexEntry,
  assignTagsIndex,
  addTagRef,
  assignCategories,
  assignTagsRefs,
  resetTagInCategories,
} = slice.actions

export const fetchCategories = () => async dispatch => {
  const categories = await apiClient.getCategories()
  dispatch(assignCategories(categories))
}

export const fetchTagsIndex = () => async dispatch => {
  const tagsRefs = await apiClient.getTagsIndex()
  dispatch(assignTagsIndex(tagsRefs))
}

export const fetchTagsIndexEntry = id => async dispatch => {
  const entry = await apiClient.getTagsIndexEntry(id)
  dispatch(addTagIndexEntry(entry))
}

export const fetchTagsRefs = () => async dispatch => {
  const tagsRefs = await apiClient.getTagsRefs()
  dispatch(assignTagsRefs(tagsRefs))
}

export const fetchTagRef = id => async dispatch => {
  const entry = await apiClient.getTagRef(id)
  dispatch(addTagRef(entry))
}

export const reloadTag = id => async(dispatch, getState) => {
  Promise.all([
    dispatch(fetchTagsIndexEntry(id)),
    dispatch(fetchTagRef(id)),
  ]).then(() => {
    const tagIndexEntry = selectTagIndexEntry(id)(getState())
    dispatch(resetTagInCategories(tagIndexEntry))
  })
}
