import { slice } from 'store/tags/slice'
import apiClient from 'store/tags/apiClient'

export const {
  addTagIndexEntry,
  assignTagsIndex,
  addTagRef,
  assignCategories,
  assignTagsRefs,
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
