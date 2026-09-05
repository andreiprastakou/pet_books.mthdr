import { selectAuthorsRefsLoaded } from 'store/authors/selectors'
import { fetchAuthorsRefs } from 'store/authors/actions'
import { selectSeriesRefsLoaded } from 'store/series/selectors'
import { fetchSeriesRefs } from 'store/series/actions'
import { selectTagsRefsLoaded } from 'store/tags/selectors'
import { fetchTagsRefs } from 'store/tags/actions'

export const prepareNavRefs = () => async(dispatch, getState) => {
  const state = getState()
  const requests = []

  const tagsLoaded = selectTagsRefsLoaded()(state)
  if (!tagsLoaded) requests.push(dispatch(fetchTagsRefs()))

  const authorsLoaded = selectAuthorsRefsLoaded()(state)
  if (!authorsLoaded) requests.push(dispatch(fetchAuthorsRefs()))

  const seriesLoaded = selectSeriesRefsLoaded()(state)
  if (!seriesLoaded) requests.push(dispatch(fetchSeriesRefs()))

  return Promise.all(requests)
}
