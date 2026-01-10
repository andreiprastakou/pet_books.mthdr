import { pull } from 'lodash'
import { fetchAuthorFull } from 'store/authors/actions'
import { selectTagBookmark, selectTagNames } from 'store/tags/selectors'
import apiClient from 'store/authors/apiClient'

export const setupStoreForAuthorCard = authorId => dispatch => {
  dispatch(fetchAuthorFull(authorId))
}

export const markAuthorAsBookmarked = (id, tagIds) => (dispatch, getState) => {
  const state = getState()
  const tagBookmark = selectTagBookmark()(state)
  const tagNames = selectTagNames(tagIds)(state)
  tagNames.push(tagBookmark)
  apiClient.putAuthorUpdates(id, { tagNames }).then(() =>
    dispatch(fetchAuthorFull(id))
  )
}

export const unmarkAuthorAsBookmarked = (id, tagIds) => (dispatch, getState) => {
  const state = getState()
  const tagBookmark = selectTagBookmark()(state)
  const tagNames = selectTagNames(tagIds)(state)
  pull(tagNames, tagBookmark)
  tagNames.push('')
  apiClient.putAuthorUpdates(id, { tagNames }).then(() =>
    dispatch(fetchAuthorFull(id))
  )
}
