import { selectAuthorsRefsLoaded } from 'store/authors/selectors'
import { fetchAuthorsRefs } from 'store/authors/actions'
import { selectTagsRefsLoaded } from 'store/tags/selectors'
import { fetchCategories, fetchTagsRefs } from 'store/tags/actions'

export const prepareNavRefs = () => async(dispatch, getState) => {
  const state = getState()
  const requests = []

  const tagsLoaded = selectTagsRefsLoaded()(state)
  if (!tagsLoaded) {
    requests.push(dispatch(fetchTagsRefs()))
    requests.push(dispatch(fetchCategories()))
  }

  const authorsLoaded = selectAuthorsRefsLoaded()(state)
  if (!authorsLoaded) requests.push(dispatch(fetchAuthorsRefs()))

  return Promise.all(requests)
}
